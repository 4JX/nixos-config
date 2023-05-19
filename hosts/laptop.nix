inputs@{ nixpkgs, home-manager, nixos-hardware, hyprland, ... }:

let
  primaryUser = "infinity";

  system = "x86_64-linux"; # System architecture

  myLib = import ../lib { };

  # An instance of Nixpkgs used solely for instatiating the custom packages with callPackage
  pkgsCall = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
  };

  # Collection of custom packages
  p = {
    legion-kb-rgb = inputs.legion-kb-rgb.packages.${system}.wrapped;
  } // (pkgsCall.callPackage ../pkgs { });


  overlay = _final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;

      config.allowUnfree = true;
    };

    # Needed for services.auto-cpufreq.enable
    inherit (p) auto-cpufreq;
  };

  patched = myLib.patchNixpkgs {
    inherit nixpkgs system;
    remoteNixpkgsPatches = [
      #   {
      #     meta.description = "PRCHANGE";
      #     url = "https://github.com/NixOS/nixpkgs/pull/PRNUMBER.diff";
      #     sha256 = "SHA256";
      #   }
    ];

    localNixpkgsPatches = [
      # ./patches/force-modesetting.diff
    ];
  };

  pkgs = import patched.nixpkgs {
    inherit system;

    config.allowUnfree = true;
    overlays = [ overlay ];
  };

  # inherit (nixpkgs) lib;
in
{
  inherit (patched) nixpkgs nixosSystem;

  cfg = {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser p;
        theme = import ../theme.nix;
      };

    modules = [
      nixos-hardware.nixosModules.lenovo-legion-16ach6h-hybrid
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        imports = [
          ../home
        ];
      }
      hyprland.nixosModules.default
      ./common.nix
      ./laptop
    ];
  };
}
