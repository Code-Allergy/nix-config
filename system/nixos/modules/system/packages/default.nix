{pkgs, ...}: {
  config = {
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
      sbctl # secureboot
      nix-index
      libsecret
      gnupg

      # android adb
      android-tools
    ];
  };
}
