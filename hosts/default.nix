{ inputs, nixpkgs, home-manager, nixos-hardware, hyprland, primaryUser, ... }:

let
  system = "x86_64-linux"; # System architecture

  overlay = _final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;

      config.allowUnfree = true;
    };

    inherit (inputs.nixpkgs-tlpui.legacyPackages.${prev.system})
      tlpui;

    inherit (inputs.nixpkgs-auto-cpufreq.legacyPackages.${prev.system})
      auto-cpufreq;

    inherit (inputs.nixpkgs-looking-glass.legacyPackages.${prev.system})
      looking-glass-client;

    legion-kb-rgb = inputs.legion-kb-rgb.packages.${prev.system}.wrapped;
  };

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    overlays = [ (import ../pkgs) overlay ];
  };

  inherit (nixpkgs) lib;
in
{
  nixos = lib.nixosSystem {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser;
        hostName = "nixos";
        theme = import ./theme.nix;
      };

    modules = [
      nixos-hardware.nixosModules.lenovo-legion-16ach6h-hybrid
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        imports = [
          ./home
        ];
      }
      hyprland.nixosModules.default
      ./configuration.nix
      ./laptop
    ];
  };
}
