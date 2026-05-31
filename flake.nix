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

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        "aarch64-linux"
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

      nixosConfigurationSpecs = {
        bigblubbus = {
          hostname = "bigblubbus";
          username = "ryan";
        };
        blubbus = {
          hostname = "blubbus";
          username = "ryan";
        };
      };

      homeConfigurationSpecs = {
        ryan = {
          system = "x86_64-linux";
          username = "ryan";
        };
      };

    in
    {
      lib = import ./lib { inherit self inputs config; } // inputs.nixpkgs.lib;
      legacyPackages = pkgsBySystem;
      packages = forEachSystem (_system: { });
      formatter = forEachSystem (system: pkgsBySystem.${system}.alejandra);
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
      nixosModules.default = import ./system/shared;
      nixosConfigurations = mapAttrs' (
        name: cfg: nameValuePair name (mkNixosSystem ({ inherit self; } // cfg))
      ) nixosConfigurationSpecs;

      homeConfigurations = mapAttrs' (
        name: cfg: nameValuePair name (mkHomeConfiguration ({ inherit self; } // cfg))
      ) homeConfigurationSpecs;

      top =
        let
          nixtop = genAttrs (builtins.attrNames self.nixosConfigurations) (
            attr: self.nixosConfigurations.${attr}.config.system.build.toplevel
          );
          hometop = genAttrs (builtins.attrNames self.homeConfigurations) (
            attr: self.homeConfigurations.${attr}.activationPackage
          );
        in
        nixtop // hometop;
    };
}
