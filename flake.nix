# TODO
# harden system - firejail, apparmor, etc
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

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

    # WSL support
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AVF (android virtualization framework) support
    nixos-avf = {
      url = "github:nix-community/nixos-avf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix for secrets
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR (nix user repository)
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland WM
    hyprland.url = "github:hyprwm/Hyprland";
    # disko.url = "github:nix-community/disko";
    # ags.url = "github:Aylur/ags"; # TODO switch to AGS over waybar.
  };

  outputs = {self, ...} @ inputs:
    with self.lib; let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSystem = genAttrs systems;
      overlayFns = attrValues (import ./nix/overlays self);
      pkgsBySystem = forEachSystem (
        system:
          import inputs.nixpkgs {
            inherit system;
            config = import ./nix/config.nix;
            overlays =
              overlayFns
              ++ [
                inputs.rust-overlay.overlays.default
                inputs.nur.overlays.default
              ];
          }
      );
    in {
      lib = import ./lib {inherit self inputs config;} // inputs.nixpkgs.lib;
      legacyPackages = pkgsBySystem;
      packages = forEachSystem (_system: {});
      formatter = forEachSystem (system: pkgsBySystem.${system}.alejandra);
      devShells = forEachSystem (system: {
        default = import ./shell.nix {pkgs = pkgsBySystem.${system};};
      });
      overlays =
        (import ./nix/overlays self)
        // {
          default = inputs.nixpkgs.lib.composeManyExtensions (
            overlayFns
            ++ [
              inputs.rust-overlay.overlays.default
              inputs.nur.overlays.default
            ]
          );
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
        hihppo = {
          user = "ryan";
          hostname = "hihppo";
          buildTarget = "nixos-wsl";
        };
        # pixel9-android-avf = {
        #   user = "ryan";
        #   hostname = "pixel9-android-avf";
        #   system = "aarch64-linux";
        #   buildTarget = "nixos-avf";
        # };
      };

      top = let
        nixtop = genAttrs (builtins.attrNames self.nixosConfigurations) (
          attr: self.nixosConfigurations.${attr}.config.system.build.toplevel
        );
        vmtop = genAttrs (builtins.attrNames self.nixosConfigurations) (
          attr: self.nixosConfigurations.${attr}.config.system.build.toplevel
        );
      in
        nixtop // vmtop;
    };
}
