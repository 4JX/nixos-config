{
  description = "Personal NixOS configuration";

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, hyprland, ... }:
    let
      myLib = import ./lib inputs;
    in
    myLib.initFlake [ "x86_64-linux" ] { allowUnfree = true; } ({ pkgs, system, ... }: {
      nixosConfigurations = import ./hosts { inherit self myLib; };

      packages.${system} = pkgs.callPackage ./pkgs { inherit myLib; };
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.url = "github:4JX/nixos-hardware";
    # nixos-hardware.url = "github:4JX/nixos-hardware/fixup";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for the pipewire low latency module
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland and co.
    hyprland.url = "github:hyprwm/Hyprland";

    xdg-portal-hyprland = {
      url = "github:hyprwm/xdg-desktop-portal-hyprland";
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    # Makes command-not-found work
    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Are you paranoid enough yet?
    arkenfox = {
      url = "github:arkenfox/user.js";
      flake = false;
    };

    # Basic theme-ing integration, might consider stylix
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # -- Extra packages --
    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
    
