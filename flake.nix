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
    nixpkgs.url = "github:4JX/nixpkgs/egui2";
    # nixpkgs.url = "github:nixos/nixpkgs/76d4d2e76b2b8281aa297d164a9eb410bf81319a";
    # Bad
    # nixpkgs.url = "github:nixos/nixpkgs/a9e00367e77d2c0b9b6f7daf9abd0fe136f3cc57";
    # nixpkgs.url = "github:nixos/nixpkgs/4ed0fc839a30003f759e12898961747688383105";
    # Good
    # nixpkgs.url = "github:nixos/nixpkgs/c7e70840c0ea981bc97a265b2294246dcc33775d";

    nixos-hardware.url = "github:nixos/nixos-hardware";

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
    # programsdb = {
    #   url = "github:wamserma/flake-programs-sqlite";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
    
