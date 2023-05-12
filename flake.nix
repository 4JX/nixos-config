{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:4JX/nixos-hardware";

    hyprland.url = "github:hyprwm/Hyprland";

    # -- Extra packages --
    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB/gui-but-better";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, hyprland, ... }:
    let
      primaryUser = "infinity";
    in
    {
      nixosConfigurations = import ./hosts {
        inherit inputs nixpkgs home-manager nixos-hardware hyprland primaryUser;
      };
    };
}
    
