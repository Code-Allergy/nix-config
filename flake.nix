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
      pkgsBySystem = forEachSystem (
        system:
        import inputs.nixpkgs {
          inherit system;
          config = import ./nix/config.nix;
          #overlays = self.overlays."${system}";
        }
      );

      nixosConfigurationSpecs = {
        bigblubbus = {
          hostname = "bigblubbus";
          username = "ryan";
          isHeaded = true;
        };
        blubbus = {
          hostname = "blubbus";
          username = "ryan";
          isHeaded = true;
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
      lib = import ./lib { inherit inputs; } // inputs.nixpkgs.lib;
      packages = forEachSystem (system: import ./nix/pkgs self system);
      formatter = forEachSystem (system: inputs.nixpkgs.legacyPackages.${system}.alejandra);
      overlay = forEachSystem (
        system: _final: _prev:
        self.packages."${system}"
      );
      overlays = forEachSystem (
        system:
        with inputs;
        let
          ovs = attrValues (import ./nix/overlays self);
        in
        [
          (self.overlay."${system}")
          # (nur.overlays.default)
          # # (_:_: { inherit (eww.packages."${system}") eww; })
        ]
        ++ ovs
      );

      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules.default = import ./system/shared;
      nixosConfigurations = mapAttrs' (
        name: cfg: nameValuePair name (neerLib.mkNixosSystem cfg)
      ) nixosConfigurationSpecs;

      homeConfigurations = mapAttrs' (
        name: cfg: nameValuePair name (neerLib.mkHomeConfiguration cfg)
      ) homeConfigurationSpecs;
    };
}
