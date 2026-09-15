{
  pkgs,
  config,
  lib,
  ...
}: let
  nvidiaOc = pkgs.writeScriptBin "nvidia-oc" (
    lib.replaceStrings ["#!/usr/bin/env python3"] ["#!${pkgs.python3}/bin/python3"] (
      builtins.readFile ../../../../scripts/nvidia-oc.py
    )
  );
  nvidiaTemperatureExport = pkgs.writeScriptBin "nvidia-temperature-export" (
    lib.replaceStrings ["#!/usr/bin/env python3"] ["#!${pkgs.python3}/bin/python3"] (
      builtins.readFile ../../../../scripts/nvidia-temperature-export.py
    )
  );
in {
  # This selects the NVIDIA driver; it does not enable a desktop.
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # The RTX 3070 supports NVIDIA's open kernel modules.
    open = true;

    modesetting.enable = true;
    nvidiaSettings = false;

    # Keep desktop/laptop power-management features out of this setup.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true;
  };

  environment.systemPackages = [
    pkgs.pciutils
    nvidiaOc
    nvidiaTemperatureExport
  ];

  systemd.services.nvidia-oc = {
    description = "Apply NVIDIA GPU clock offsets";
    wantedBy = ["multi-user.target"];
    requires = ["nvidia-persistenced.service"];
    after = ["nvidia-persistenced.service"];
    before = ["podman-llama-swap.service"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${nvidiaOc}/bin/nvidia-oc --memory-offset 2600 --core-offset 95";
      RemainAfterExit = true;
    };
  };

  systemd.services.nvidia-temperature-export = {
    description = "Export NVIDIA GPU temperature over QEMU virtio-serial";
    wantedBy = ["multi-user.target"];
    requires = ["nvidia-persistenced.service"];
    after = [
      "nvidia-persistenced.service"
      "nvidia-oc.service"
    ];
    before = ["podman-llama-swap.service"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${nvidiaTemperatureExport}/bin/nvidia-temperature-export";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
