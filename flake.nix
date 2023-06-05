{
  description = "Personal NixOS configuration";

  outputs = inputs:
    let
      machines = builtins.mapAttrs
        (machineName: machineConfig:
          let
            inherit (import machineConfig inputs) cfg nixosSystem nixpkgs;
          in

          nixosSystem (cfg // {
            specialArgs = {
              inherit machineName;
            } // (cfg.specialArgs or { });

            modules = cfg.modules ++ [
              ./modules
              (_: {

                # Resolve <nixpkgs> and other references to the flake input
                # https://ayats.org/blog/channels-to-flakes/
                environment.etc."nix/inputs/nixpkgs".source = nixpkgs.outPath;
                nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
                nix.registry.nixpkgs.flake = nixpkgs;

                # Needed for all configs to run on flakes
                nix.settings.experimental-features = [ "nix-command" "flakes" ];
              })
            ];
          })
        );
    in
    {
      nixosConfigurations = machines {
        nixos = ./hosts/laptop.nix;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-gnomeext.url = "github:4JX/nixpkgs/gnomeExt-compile-schemas";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    # -- Extra packages --
    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB/gui-but-better";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
    
