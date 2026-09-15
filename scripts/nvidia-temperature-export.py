#!/usr/bin/env python3
"""Export an NVIDIA GPU temperature over a virtio-serial port."""

from __future__ import annotations

import argparse
import ctypes as C
import ctypes.util
import os
import sys
import time
from pathlib import Path

NVML_SUCCESS = 0
NVML_TEMPERATURE_GPU = 0


class NvmlError(RuntimeError):
    pass


class NVML:
    def __init__(self):
        self.lib = self._load_library()

        self.lib.nvmlInit_v2.argtypes = []
        self.lib.nvmlInit_v2.restype = C.c_int
        self.lib.nvmlShutdown.argtypes = []
        self.lib.nvmlShutdown.restype = C.c_int
        self.lib.nvmlErrorString.argtypes = [C.c_int]
        self.lib.nvmlErrorString.restype = C.c_char_p

        self.get_handle = getattr(self.lib, "nvmlDeviceGetHandleByIndex_v2", None)
        if self.get_handle is None:
            self.get_handle = self.lib.nvmlDeviceGetHandleByIndex
        self.get_handle.argtypes = [C.c_uint, C.POINTER(C.c_void_p)]
        self.get_handle.restype = C.c_int

        self.get_temperature = self.lib.nvmlDeviceGetTemperature
        self.get_temperature.argtypes = [C.c_void_p, C.c_int, C.POINTER(C.c_uint)]
        self.get_temperature.restype = C.c_int

        self._check(self.lib.nvmlInit_v2(), "nvmlInit_v2")

    @staticmethod
    def _load_library():
        candidates = []
        env = os.environ.get("NVML_LIBRARY")
        if env:
            candidates.append(env)
        found = ctypes.util.find_library("nvidia-ml")
        if found:
            candidates.append(found)
        candidates += [
            "/run/opengl-driver/lib/libnvidia-ml.so.1",
            "/usr/lib/libnvidia-ml.so.1",
            "/usr/lib64/libnvidia-ml.so.1",
            "libnvidia-ml.so.1",
        ]

        errors = []
        for candidate in dict.fromkeys(candidates):
            try:
                return C.CDLL(candidate)
            except OSError as exc:
                errors.append(f"{candidate}: {exc}")
        raise NvmlError(
            "Could not load libnvidia-ml.so.1. Tried:\n  " + "\n  ".join(errors)
        )

    def _check(self, rc: int, operation: str):
        if rc != NVML_SUCCESS:
            raw = self.lib.nvmlErrorString(rc)
            message = raw.decode("utf-8", "replace") if raw else f"NVML error {rc}"
            raise NvmlError(f"{operation}: {message} (NVML {rc})")

    def device(self, index: int) -> C.c_void_p:
        handle = C.c_void_p()
        self._check(self.get_handle(index, C.byref(handle)), f"GPU {index}")
        return handle

    def temperature(self, device: C.c_void_p) -> int:
        value = C.c_uint()
        self._check(
            self.get_temperature(device, NVML_TEMPERATURE_GPU, C.byref(value)),
            "nvmlDeviceGetTemperature",
        )
        return value.value

    def shutdown(self):
        try:
            self.lib.nvmlShutdown()
        except Exception:
            pass


def sample(temperature: int) -> str:
    return f"{temperature}\n"


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--gpu", type=int, default=0, help="GPU index (default: 0)")
    parser.add_argument(
        "--port",
        type=Path,
        default=Path("/dev/virtio-ports/org.neer.nvidia.temperature"),
        help="virtio-serial port path",
    )
    parser.add_argument(
        "--interval",
        type=float,
        default=2.0,
        help="seconds between samples (default: 2)",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.interval <= 0:
        print("error: --interval must be greater than zero", file=sys.stderr)
        return 2

    while True:
        nvml = None
        try:
            nvml = NVML()
            device = nvml.device(args.gpu)

            while True:
                if not args.port.exists():
                    print(f"waiting for virtio-serial port {args.port}", file=sys.stderr)
                    time.sleep(args.interval)
                    continue

                try:
                    # Reopen on every connection so a host-side channel reconnect
                    # does not require restarting this service.
                    fd = os.open(args.port, os.O_WRONLY)
                    with os.fdopen(fd, "w", encoding="ascii", buffering=1) as port:
                        while True:
                            port.write(sample(nvml.temperature(device)))
                            port.flush()
                            time.sleep(args.interval)
                except (BrokenPipeError, OSError) as exc:
                    print(f"virtio-serial port disconnected: {exc}", file=sys.stderr)
                    time.sleep(args.interval)
        except (NvmlError, OSError) as exc:
            print(f"NVIDIA temperature exporter unavailable: {exc}", file=sys.stderr)
            time.sleep(max(args.interval, 5.0))
        finally:
            if nvml is not None:
                nvml.shutdown()


if __name__ == "__main__":
    raise SystemExit(main())
