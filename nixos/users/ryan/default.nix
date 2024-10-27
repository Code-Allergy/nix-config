{pkgs, ...}: {
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    initialPassword = "CHANGEME123!";
    extraGroups = ["plugdev" "networkmanager" "wheel" "podman" "docker" "libvirtd" "audio" "video" "kvm" "adbusers" "dialout"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE4N8Fiv6jdkPy8yMeE35HoFypjobZ2sq1I/G8iWui5T ryan@rys686@usask.ca"
    ];
    shell = pkgs.fish;
  };
}
