{pkgs, ...}: {
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    initialPassword = "CHANGEME123!";
    extraGroups = ["plugdev" "networkmanager" "wheel" "podman" "docker" "libvirtd" "audio" "video"];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjL6VXXuid4Dq7QbRUPgpFxqOvyNstWtOt/LXiGBPdtQRx979YNI27KtP8x+ysYifrcU0cksfetaHj5UZCEmre5iG78vZ4/svtouEjh6oCUGwCTrVUCN63cuTKtDSTAzBGd/jBFyUZo1SBAtpuQ/gKKvAX6WK1OcAg8SRSpeOhjK4r/jT/2vNEkJePNDJk+uw5uQdHynqrt+eSF6aQG7SZo+nG3S55MdWnlRuKIEfOOq0jt09SPxJ8GB0HpjvZhON/KdjHlAZDUPVui2bBhF0S/umzMyCsR6z3478uGijM9QcMGlpV8RjTqDa5BnngaKoNLc6RnFHjhdkEVLBVJVBUpjsnQbp8oYHMhbzTNgisuuiSHJUtljUIGIcLAe76Yxp3+lUPSYFzxZZp7m+sKUPnHYn/guVdUzJzk6nQXJiwoaV5vXMLsrWPMQJIwNpruGbUID3gkmhS0rs7y1TR0pHjcqfUlHWSrYqIB7gETsCJUjHOiGQm138BVsvYlnz9AH0= ryan@fedora"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCHqmSLKCBzV4VEdq/ey2UdtAo+H1dPGFh/MAMqrCMJxnwwTH7aYtKQmCr0e91fbCkmqRLwtVbX5keSwbpOWACAnPNuxCSuazuJ/PCKEcbTG92iZfK1tsbkd+JniLybn1wHtFPOGyvQpzNpKWVdFMiH0jbzxbrfYOVLiUacCsRiSWFLeS52KOgVzNckeZaJwQE+2Y40rCf1UTfI53FH4C+0SKQLNk9tqCgWaraDhZCrAhMwlRzsV6lWbCyCZMkO4Q92SQPhJdQ2y9eJ0A4x5WQE2YZVFmQTFQ5+nZZnLxhOmuJnUpwBAifU8PP7TwAVBzb4o1fm6TYfIjpj5HVD364E9MwEChyf3+XgIESmzSsr+XES6GaGF29m5LLYgM3spAbJviLTfjYIMGwpVSXW+j8HWxzhDDEZNC/6AAuuhdWRQYyQWcA72yPsMpKXaDH0PT3EeqABUx/uySKW+BAYLODG78Tft6gCbIBWseujlQywij2l5T3muABnHD86nbpbhKE= ryan@arch.fedora"
    ];
    shell = pkgs.fish;
  };
}
