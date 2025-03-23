#!/bin/sh

hypridle &
hyprsunset &
hyprnotify &
systemctl --user start hyprpolkitagent &
copyq --start-server

# systemctl --user start plasma-polkit-agent &
syncthingtray --wait &

if [ $HOSTNAME = "bigblubbus" ]; then
    vesktop --start-minimized &
    steam -silent &
    corectrl --minimize-systray &
fi

if [ $HOSTNAME = "blubbus" ]; then
    # Shrug
fi
