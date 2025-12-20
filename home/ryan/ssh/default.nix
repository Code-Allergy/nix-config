{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "tuxworld" = {
        hostname = "tuxworld.usask.ca";
        user = "rys686";
      };
      "tower" = {
        hostname = "10.10.10.10";
        user = "root";
      };

      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };
}
