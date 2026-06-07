{pkgs, ...}: {
  config = {
    # default shell tools I expect everywhere
    home.packages = with pkgs; [
      # run any package with ,
      comma

      # CLI tools we want everywhere
      htop
      bottom
      eza
      killall
      file

      # network tools
      wget
      curl

      # sshfs
      sshfs
    ];

    # enable bat program
    programs.bat.enable = true;

    # enable FUCK
    programs.pay-respects.enable = true;
  };
}
