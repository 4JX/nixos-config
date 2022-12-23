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
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      primaryUser = "infinity";
    in
    {
      nixosConfigurations = (
        import ./hosts {
          inherit inputs nixpkgs home-manager nixos-hardware primaryUser;
        }
      );
    };
}
    
