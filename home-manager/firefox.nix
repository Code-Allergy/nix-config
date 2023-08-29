{ config, ... }: {
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        # extensions = with config.nur.repos.rycee.firefox-addons; [
        #   ublock-origin
        # ];
      };
    };
  };
}