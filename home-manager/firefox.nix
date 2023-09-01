{config, ...}: {
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        extensions = with config.nur.repos.rycee.firefox-addons; [
          betterttv
          # unclosetabbutton
          # tridactyl
          bitwarden
          return-youtube-dislikes
          sponsorblock
          protondb-for-steam
          enhancer-for-youtube
          ublock-origin

          facebook-container
          wayback-machine
          view-image
        ];
      };
    };
  };
}
