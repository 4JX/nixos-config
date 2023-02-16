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

    # -- Extra packages --
    # TLPUI
    nixpkgs-tlpui = {
      url = "https://github.com/NixOS/nixpkgs/archive/55cf28e91d51df77932da6c12dbf1b98ffa697b0.tar.gz";
    };

    # auto-cpufreq 1.9.6
    nixpkgs-auto-cpufreq = {
      url = "https://github.com/NixOS/nixpkgs/archive/de3ec7b577e5d6114b7631efb50c998e88798e22.tar.gz";
    };

    # looking-glass B6
    nixpkgs-looking-glass = {
      url = "https://github.com/NixOS/nixpkgs/archive/9fa5c1f0a85f83dfa928528a33a28f063ae3858d.tar.gz";
    };

    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB/gui-but-better";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, nixos-hardware, ... }:
    let
      primaryUser = "infinity";
    in
    {
      nixosConfigurations = import ./hosts {
        inherit inputs nixpkgs home-manager nixos-hardware primaryUser;
      };
    };
}
    
