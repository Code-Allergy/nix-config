{pkgs, ...}: {
  # gnome-keyring
  services.gnome-keyring = {
    enable = true;
    components = ["pkcs11" "secrets" "ssh"];
  };

  systemd.user.services.keyring-daemon = {
    Unit = {
      Description = "GNOME Keyring daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.gnome.gnome-keyring}/bin/gnome-keyring-daemon --foreground --components=secrets,ssh,pkcs11";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.ssh.addKeysToAgent = "yes";

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
}
