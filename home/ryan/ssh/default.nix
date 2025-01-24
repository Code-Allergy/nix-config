{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host vada.life
        User root
        HostName vada.life
        IdentityFile ~/.ssh/id_ed25519

      Host blubbus
        HostName 192.168.1.206
        User ryan

      Host bigblubbus
        HostName 192.168.1.124
        User ryan

      Host tuxworld
        HostName tuxworld.usask.ca
        User rys686

      Host cmpt332-amd64
        HostName cmpt332-amd64
        User rys686
        ProxyJump tuxworld

      Host cmpt332-arm
        HostName cmpt332-arm
        User rys686
        ProxyJump tuxworld

      Host cmpt332-ppc
        HostName cmpt332-ppc
        User rys686
        ProxyJump tuxworld

      Host trux
        HostName trux
        User rys686
        ProxyJump tuxworld
    '';
  };
}
