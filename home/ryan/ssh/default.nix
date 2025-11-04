{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "tuxworld" = {
        hostname = "tuxworld.usask.ca";
        user = "rys686";
      };

      "*" = {
        addKeysToAgent = "yes";
      };
    };
  };
}
