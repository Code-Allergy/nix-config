{

  programs.autorandr = {
    enable = true;

    hooks = {};

    profiles = {
      "default" = {
        fingerprint = {
          Virtual-1 = "--CONNECTED-BUT-EDID-UNAVAILABLE--Virtual-1"; };
        config = {
          Virtual-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };
  };
}