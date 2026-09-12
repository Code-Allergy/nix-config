#!/bin/sh
set -eu

cache=${MODEL_CACHE_DIRECTORY:-/models}
source=${MODEL_CATALOG_DIRECTORY:-/model-catalog}
limit=${MODEL_CACHE_MAX_BYTES:?MODEL_CACHE_MAX_BYTES must be set}
lock="$cache/.cache-lock"

mkdir -p "$cache"

attempt=0
while ! mkdir "$lock" 2>/dev/null; do
  attempt=$((attempt + 1))

  if [ "$attempt" -ge 300 ]; then
    echo "timed out waiting for the model cache lock" >&2
    exit 1
  fi

  if find "$lock" -maxdepth 0 -mmin +60 -print -quit 2>/dev/null | grep -q .; then
    rm -rf "$lock"
    continue
  fi

  sleep 1
done

trap 'rm -rf "$lock"' 0 HUP INT TERM
printf '%s\n' "$$" > "$lock/pid"
: > "$lock/requested"

while [ "$#" -gt 0 ] && [ "$1" != "--" ]; do
  relative=$1
  case "$relative" in
    "" | /* | ../* | */../* | */..)
      echo "invalid model cache path: $relative" >&2
      exit 1
      ;;
  esac

  printf '%s\n' "$relative" >> "$lock/requested"
  shift
done

if [ "$#" -eq 0 ]; then
  echo "model cache wrapper requires -- followed by a command" >&2
  exit 1
fi
shift

if [ "$#" -eq 0 ]; then
  echo "model cache wrapper requires a command to execute" >&2
  exit 1
fi

find "$cache" -type f -name '*.partial.*' -delete

requested_size=0
missing_size=0

while IFS= read -r relative; do
  destination="$cache/$relative"

  if [ -f "$destination" ]; then
    size=$(stat -c %s "$destination")
    requested_size=$((requested_size + size))
    touch "$destination"
    continue
  fi

  origin="$source/$relative"
  if [ ! -f "$origin" ]; then
    echo "model file is not cached and does not exist in the catalog: $relative" >&2
    exit 1
  fi

  size=$(stat -c %s "$origin")
  requested_size=$((requested_size + size))
  missing_size=$((missing_size + size))
done < "$lock/requested"

if [ "$requested_size" -gt "$limit" ]; then
  echo "requested model files require $requested_size bytes, exceeding the $limit byte cache limit" >&2
  exit 1
fi

usage=$(du -sb --exclude='.cache-lock' "$cache" | awk '{print $1}')
while [ $((usage + missing_size)) -gt "$limit" ]; do
  candidate=$(
    find "$cache" -type f \
      ! -path "$lock/*" \
      ! -name '*.partial.*' \
      -printf '%T@ %P\n' \
      | sort -n \
      | while IFS=' ' read -r _ relative; do
          if ! grep -Fxq "$relative" "$lock/requested"; then
            printf '%s\n' "$relative"
            break
          fi
        done
  )

  if [ -z "$candidate" ]; then
    echo "model cache cannot free enough space for the requested files" >&2
    exit 1
  fi

  echo "evicting least-recently-used model file: $candidate" >&2
  rm -f "$cache/$candidate"
  usage=$(du -sb --exclude='.cache-lock' "$cache" | awk '{print $1}')
done

while IFS= read -r relative; do
  destination="$cache/$relative"
  if [ -f "$destination" ]; then
    touch "$destination"
    continue
  fi

  origin="$source/$relative"
  parent=$(dirname "$destination")
  partial="$destination.partial.$$"

  mkdir -p "$parent"
  echo "caching model file: $relative" >&2
  cp "$origin" "$partial"
  mv -f "$partial" "$destination"
  touch "$destination"
done < "$lock/requested"

rm -rf "$lock"
trap - 0 HUP INT TERM
exec "$@"
