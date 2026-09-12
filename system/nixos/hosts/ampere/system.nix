{ lib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    # temp nvidia module because other nvidia module is too coupled with blubbus
    ./nvidia.nix
  ];

  time.timeZone = "America/Regina";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  xdg.portal.enable = true;

  services.qemuGuest.enable = true;

  # this will be in compute module
  hardware.nvidia-container-toolkit.enable = true;

  # extra user for deploying certs, likely make this modular if we use it on more servers and my home pc.
  users.groups.cert-deploy = { };

  users.users.certsync = {
    isSystemUser = true;
    group = "cert-deploy";

    # SFTP starts here, although OPNsense can also use the absolute remote path.
    home = "/var/lib/caddy/certs";
    createHome = false;

    # ForceCommand below prevents this account from obtaining a shell.
    shell = pkgs.bashInteractive;

    # Add the OPNsense-generated public key here in step 4.
    openssh.authorizedKeys.keys = [
      "restrict,from=\"10.10.0.1\" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+5TwqdSKk9szm4YC6tYYovLy6vumlUhYKCNYidgF8Q root@router.lan"
    ];
  };

  services.openssh.extraConfig = ''
    Match User certsync
      AuthenticationMethods publickey
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      ForceCommand internal-sftp
      PermitTTY no
      AllowTcpForwarding no
      X11Forwarding no
      PermitTunnel no
      PermitUserRC no

    Match all
  '';
}
