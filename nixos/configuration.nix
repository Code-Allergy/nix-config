{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  imports = [
    
    ./fonts.nix
    # TMP

    # <home-manager/nixos>
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      ryan = import ../home/ryan/home.nix;
    };
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_licence = true;
  };

  nix = {
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    extraOptions = ''
      experimental-features = nix-command flakes
      auto-optimise-store = true
      keep-outputs = true
      keep-derivations = true
      cores = 6
      max-jobs = 6
      max-free = ${toString (500 * 1024 * 1024)}
    '';

    gc = {
      automatic = true;
      dates = "weekly";
      options = "";
    };
  };

  # TODO blubbus networking
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim-full
    mupdf
    wget
    git

    kdePackages.polkit-kde-agent-1

    # dotfiles
    git-crypt
    stow

    # temp -- needed for waybar, put somewhere else
    python3

    # add distrobox
    distrobox
    boxbuddy
  ];

  home-manager.useUserPackages = true;

  # users.users.ryan = {
  #   isNormalUser = true;
  #   extraGroups = ["wheel" "docker" "libvirtd"];
  #   openssh.authorizedKeys.keys = [
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCjL6VXXuid4Dq7QbRUPgpFxqOvyNstWtOt/LXiGBPdtQRx979YNI27KtP8x+ysYifrcU0cksfetaHj5UZCEmre5iG78vZ4/svtouEjh6oCUGwCTrVUCN63cuTKtDSTAzBGd/jBFyUZo1SBAtpuQ/gKKvAX6WK1OcAg8SRSpeOhjK4r/jT/2vNEkJePNDJk+uw5uQdHynqrt+eSF6aQG7SZo+nG3S55MdWnlRuKIEfOOq0jt09SPxJ8GB0HpjvZhON/KdjHlAZDUPVui2bBhF0S/umzMyCsR6z3478uGijM9QcMGlpV8RjTqDa5BnngaKoNLc6RnFHjhdkEVLBVJVBUpjsnQbp8oYHMhbzTNgisuuiSHJUtljUIGIcLAe76Yxp3+lUPSYFzxZZp7m+sKUPnHYn/guVdUzJzk6nQXJiwoaV5vXMLsrWPMQJIwNpruGbUID3gkmhS0rs7y1TR0pHjcqfUlHWSrYqIB7gETsCJUjHOiGQm138BVsvYlnz9AH0= ryan@fedora"
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCHqmSLKCBzV4VEdq/ey2UdtAo+H1dPGFh/MAMqrCMJxnwwTH7aYtKQmCr0e91fbCkmqRLwtVbX5keSwbpOWACAnPNuxCSuazuJ/PCKEcbTG92iZfK1tsbkd+JniLybn1wHtFPOGyvQpzNpKWVdFMiH0jbzxbrfYOVLiUacCsRiSWFLeS52KOgVzNckeZaJwQE+2Y40rCf1UTfI53FH4C+0SKQLNk9tqCgWaraDhZCrAhMwlRzsV6lWbCyCZMkO4Q92SQPhJdQ2y9eJ0A4x5WQE2YZVFmQTFQ5+nZZnLxhOmuJnUpwBAifU8PP7TwAVBzb4o1fm6TYfIjpj5HVD364E9MwEChyf3+XgIESmzSsr+XES6GaGF29m5LLYgM3spAbJviLTfjYIMGwpVSXW+j8HWxzhDDEZNC/6AAuuhdWRQYyQWcA72yPsMpKXaDH0PT3EeqABUx/uySKW+BAYLODG78Tft6gCbIBWseujlQywij2l5T3muABnHD86nbpbhKE= ryan@arch.fedora"
  #   ];
  # };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Do NOT change this value, For more information, see `man configuration.nix`
  # or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion.
  system.stateVersion = "24.05";
}
