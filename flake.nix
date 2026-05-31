# TODO
# harden system - firejail, apparmor, etc
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    # REQUIRES sbctl generate keys at /etc/secureboot
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-on-droid (Android)
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # # agenix for secrets (used by some droid helpers)
    # agenix = {
    #   url = "github:ryantm/agenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Hyprland WM
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # disko.url = "github:nix-community/disko";
    # ags.url = "github:Aylur/ags"; # TODO switch to AGS over waybar.
  };

  outputs =
    {
      self,
      ...
    }@inputs:
    with self.lib;
    let
      systems = [
        "x86_64-linux"
      ];
      forEachSystem = genAttrs systems;
      # overlayList = builtins.attrValues (import ./nix/overlays self);
      pkgsBySystem = forEachSystem (
        system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nix/config.nix;
          # overlays = overlayList;
        }
      );

    in
    {
      lib = import ./lib { inherit self inputs config; } // inputs.nixpkgs.lib;
      legacyPackages = pkgsBySystem;
      packages = forEachSystem (_system: { });
      formatter = forEachSystem (system: pkgsBySystem.${system}.alejandra);
      devShells = forEachSystem (system: {
        default = import ./shell.nix { pkgs = pkgsBySystem.${system}; };
      });
      # overlay = forEachSystem (
      #   system: _final: _prev:
      #   self.packages."${system}"
      # );
      # overlays = forEachSystem (
      #   system:
      #   with inputs;
      #   let
      #     # ovs = attrValues (import ./nix/overlays self);
      #   in
      #   [
      #     # (self.overlay."${system}")
      #     # (nur.overlays.default)
      #     # (_:_: { inherit (eww.packages."${system}") eww; })
      #   ]
      #   # ++ ovs
      # );

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      # nixosModules.default = import ./system/shared;
      # nixosConfigurations = mapAttrs' (
      #   name: cfg: nameValuePair name (mkNixosSystem ({ inherit self; } // cfg))
      # ) nixosConfigurationSpecs;
      #

      nixOnDroidConfigurations = mapAttrs' mkNixOnDroidConfiguration {
        default = {
          user = "droid";
        };
      };

      nixosConfigurations = mapAttrs' mkNixSystemConfiguration {
        bigblubbus = {
          user = "ryan";
          hostname = "bigblubbus";
          buildTarget = "nixos";
        };
        blubbus = {
          user = "ryan";
          hostname = "blubbus";
          buildTarget = "nixos";
        };
      };

      top =
        let
          droidtop = genAttrs (builtins.attrNames inputs.self.nixOnDroidConfigurations) (
            attr: inputs.self.nixOnDroidConfigurations.${attr}.config.system.build.toplevel
          );
          nixtop = genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
            attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel
          );
          # hometop = genAttrs (builtins.attrNames inputs.self.homeConfigurations) (
          #   attr: inputs.self.homeConfigurations.${attr}.activationPackage
          # );
          # darwintop = genAttrs (builtins.attrNames inputs.self.darwinConfigurations) (
          #   attr: inputs.self.darwinConfigurations.${attr}.system
          # );
          vmtop = genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
            attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel
          );
        in
        droidtop // nixtop;
      # droidtop // nixtop // hometop // darwintop // vmtop;
    };
}
