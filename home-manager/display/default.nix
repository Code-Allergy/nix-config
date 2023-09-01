{
  programs.autorandr = {
    enable = true;

    hooks = {};

    profiles = {
      "default" = {
        fingerprint = {
          Virtual-1 = "00ffffffffffff0049143412000000002a180104a520147806ee91a3544c99260f5054210800e1c0d1c0d100a940b300950081808140ea2900c051201c304026444045cb10000018000000f7000a004082002820000000000000000000fd00327d1ea0ff010a202020202020000000fc0051454d55204d6f6e69746f720a013a02030b00467d6560591f6100000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000010000000000000000000000000000000000000000000002f";
        };
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
