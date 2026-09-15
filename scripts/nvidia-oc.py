#!/usr/bin/env python3
"""Headless NVIDIA clock-offset utility using NVML directly.

Examples:
  ./nvidia-oc.py --query
  sudo ./nvidia-oc.py --memory-offset 1000
  sudo ./nvidia-oc.py --memory-offset 1000 --core-offset 100
  sudo ./nvidia-oc.py --reset

Offsets are the MHz values reported/accepted by NVML's VF-offset API.
No X server or nvidia-settings is required.
"""

from __future__ import annotations

import argparse
import ctypes as C
import ctypes.util
import os
import sys
from pathlib import Path

NVML_SUCCESS = 0


class NvmlError(RuntimeError):
    pass


class NVML:
    def __init__(self, library: str | None = None):
        self.lib = self._load_library(library)
        self._bind()
        self._check(self.lib.nvmlInit_v2(), "nvmlInit_v2")

    @staticmethod
    def _load_library(explicit: str | None):
        candidates: list[str] = []
        if explicit:
            candidates.append(explicit)
        env = os.environ.get("NVML_LIBRARY")
        if env:
            candidates.append(env)
        found = ctypes.util.find_library("nvidia-ml")
        if found:
            candidates.append(found)
        candidates += [
            "/run/opengl-driver/lib/libnvidia-ml.so.1",  # NixOS
            "/usr/lib/libnvidia-ml.so.1",
            "/usr/lib64/libnvidia-ml.so.1",
            "libnvidia-ml.so.1",
        ]

        errors: list[str] = []
        for candidate in dict.fromkeys(candidates):
            try:
                return C.CDLL(candidate)
            except OSError as exc:
                errors.append(f"{candidate}: {exc}")
        raise NvmlError(
            "Could not load libnvidia-ml.so.1. Tried:\n  " + "\n  ".join(errors)
        )

    def _bind(self):
        L = self.lib

        L.nvmlInit_v2.argtypes = []
        L.nvmlInit_v2.restype = C.c_int
        L.nvmlShutdown.argtypes = []
        L.nvmlShutdown.restype = C.c_int
        L.nvmlErrorString.argtypes = [C.c_int]
        L.nvmlErrorString.restype = C.c_char_p

        # Prefer v2 handle lookup, but support older libraries too.
        self.get_handle_fn = getattr(L, "nvmlDeviceGetHandleByIndex_v2", None)
        if self.get_handle_fn is None:
            self.get_handle_fn = L.nvmlDeviceGetHandleByIndex
        self.get_handle_fn.argtypes = [C.c_uint, C.POINTER(C.c_void_p)]
        self.get_handle_fn.restype = C.c_int

        L.nvmlDeviceGetName.argtypes = [C.c_void_p, C.c_char_p, C.c_uint]
        L.nvmlDeviceGetName.restype = C.c_int

        # These APIs are available in production drivers >= 520. They are
        # deprecated by newer NVML in favor of nvmlDevice*ClockOffsets(), but
        # remain useful for a tiny ABI-only tool because they need no structs.
        self.get_mem = self._optional("nvmlDeviceGetMemClkVfOffset", [C.c_void_p, C.POINTER(C.c_int)])
        self.get_mem_range = self._optional(
            "nvmlDeviceGetMemClkMinMaxVfOffset",
            [C.c_void_p, C.POINTER(C.c_int), C.POINTER(C.c_int)],
        )
        self.set_mem = self._optional("nvmlDeviceSetMemClkVfOffset", [C.c_void_p, C.c_int])

        self.get_core = self._optional("nvmlDeviceGetGpcClkVfOffset", [C.c_void_p, C.POINTER(C.c_int)])
        self.get_core_range = self._optional(
            "nvmlDeviceGetGpcClkMinMaxVfOffset",
            [C.c_void_p, C.POINTER(C.c_int), C.POINTER(C.c_int)],
        )
        self.set_core = self._optional("nvmlDeviceSetGpcClkVfOffset", [C.c_void_p, C.c_int])

    def _optional(self, name: str, argtypes):
        fn = getattr(self.lib, name, None)
        if fn is not None:
            fn.argtypes = argtypes
            fn.restype = C.c_int
        return fn

    def error_string(self, rc: int) -> str:
        try:
            raw = self.lib.nvmlErrorString(rc)
            return raw.decode("utf-8", "replace") if raw else f"NVML error {rc}"
        except Exception:
            return f"NVML error {rc}"

    def _check(self, rc: int, op: str):
        if rc != NVML_SUCCESS:
            raise NvmlError(f"{op}: {self.error_string(rc)} (NVML {rc})")

    def device(self, index: int) -> C.c_void_p:
        handle = C.c_void_p()
        self._check(self.get_handle_fn(index, C.byref(handle)), f"GPU {index}")
        return handle

    def name(self, device: C.c_void_p) -> str:
        buf = C.create_string_buffer(256)
        self._check(self.lib.nvmlDeviceGetName(device, buf, len(buf)), "nvmlDeviceGetName")
        return buf.value.decode("utf-8", "replace")

    def query_value(self, fn, device, label: str) -> tuple[int | None, str | None]:
        if fn is None:
            return None, "API symbol unavailable"
        value = C.c_int()
        rc = fn(device, C.byref(value))
        if rc != NVML_SUCCESS:
            return None, self.error_string(rc)
        return value.value, None

    def query_range(self, fn, device, label: str) -> tuple[tuple[int, int] | None, str | None]:
        if fn is None:
            return None, "API symbol unavailable"
        lo, hi = C.c_int(), C.c_int()
        rc = fn(device, C.byref(lo), C.byref(hi))
        if rc != NVML_SUCCESS:
            return None, self.error_string(rc)
        return (lo.value, hi.value), None

    def set_value(self, fn, device, value: int, label: str):
        if fn is None:
            raise NvmlError(f"{label}: setter API symbol is unavailable in this NVML library")
        rc = fn(device, int(value))
        self._check(rc, f"set {label} offset to {value} MHz")

    def shutdown(self):
        try:
            self.lib.nvmlShutdown()
        except Exception:
            pass


def print_status(nvml: NVML, device, gpu: int):
    print(f"GPU {gpu}: {nvml.name(device)}")

    mem, mem_err = nvml.query_value(nvml.get_mem, device, "memory")
    mem_range, mem_range_err = nvml.query_range(nvml.get_mem_range, device, "memory")
    core, core_err = nvml.query_value(nvml.get_core, device, "core")
    core_range, core_range_err = nvml.query_range(nvml.get_core_range, device, "core")

    def row(name, value, value_err, rng, rng_err):
        current = f"{value:+d} MHz" if value is not None else f"unsupported ({value_err})"
        limits = f"{rng[0]:+d}..{rng[1]:+d} MHz" if rng is not None else f"unsupported ({rng_err})"
        print(f"  {name:<7} current: {current}")
        print(f"  {name:<7} range:   {limits}")

    row("memory", mem, mem_err, mem_range, mem_range_err)
    row("core", core, core_err, core_range, core_range_err)


def validate(nvml: NVML, device, value: int, range_fn, label: str):
    rng, _ = nvml.query_range(range_fn, device, label)
    if rng is not None and not (rng[0] <= value <= rng[1]):
        raise NvmlError(
            f"{label} offset {value:+d} MHz is outside the device-reported "
            f"range {rng[0]:+d}..{rng[1]:+d} MHz"
        )


def parse_args():
    p = argparse.ArgumentParser(
        prog="nvidia-oc",
        description="Headless NVIDIA GPU VF clock-offset utility using NVML.",
    )
    p.add_argument("-i", "--gpu", type=int, default=0, help="GPU index (default: 0)")
    p.add_argument("--library", help="explicit path to libnvidia-ml.so.1")
    p.add_argument("-q", "--query", action="store_true", help="show current offsets and supported ranges")
    p.add_argument("--memory-offset", type=int, metavar="MHz", help="set memory VF offset")
    p.add_argument("--core-offset", type=int, metavar="MHz", help="set GPC/core VF offset")
    p.add_argument("--reset", action="store_true", help="set both memory and core offsets to 0")
    return p.parse_args()


def main() -> int:
    args = parse_args()

    if args.reset and (args.memory_offset is not None or args.core_offset is not None):
        print("error: --reset cannot be combined with --memory-offset/--core-offset", file=sys.stderr)
        return 2

    modifying = args.reset or args.memory_offset is not None or args.core_offset is not None
    if not modifying and not args.query:
        args.query = True

    nvml = None
    try:
        nvml = NVML(args.library)
        device = nvml.device(args.gpu)

        if args.query and not modifying:
            print_status(nvml, device, args.gpu)
            return 0

        if modifying and hasattr(os, "geteuid") and os.geteuid() != 0:
            print("warning: NVML clock setters normally require root; this operation may fail", file=sys.stderr)

        if args.reset:
            nvml.set_value(nvml.set_mem, device, 0, "memory")
            nvml.set_value(nvml.set_core, device, 0, "core")
            print("Reset memory and core VF offsets to 0 MHz.")
        else:
            if args.memory_offset is not None:
                validate(nvml, device, args.memory_offset, nvml.get_mem_range, "memory")
                nvml.set_value(nvml.set_mem, device, args.memory_offset, "memory")
                print(f"Set memory VF offset to {args.memory_offset:+d} MHz.")
            if args.core_offset is not None:
                validate(nvml, device, args.core_offset, nvml.get_core_range, "core")
                nvml.set_value(nvml.set_core, device, args.core_offset, "core")
                print(f"Set core/GPC VF offset to {args.core_offset:+d} MHz.")

        print_status(nvml, device, args.gpu)
        return 0
    except NvmlError as exc:
        print(f"error: {exc}", file=sys.stderr)
        print(
            "hint: if NVML reports 'Not Supported', the installed NVIDIA driver/GPU "
            "does not expose writable VF offsets through this API.",
            file=sys.stderr,
        )
        return 1
    finally:
        if nvml is not None:
            nvml.shutdown()


if __name__ == "__main__":
    raise SystemExit(main())
