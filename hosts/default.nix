{ inputs, home-manager, nixos-hardware, hyprland, primaryUser, ... }:

let
  system = "x86_64-linux"; # System architecture

  # An instance of Nixpkgs used solely for instatiating the custom packages with callPackage
  pkgsCall = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
  };

  # Collection of custom packages
  p = {
    legion-kb-rgb = inputs.legion-kb-rgb.packages.${system}.wrapped;
  } // (pkgsCall.callPackage ../pkgs { });

  # Allow patching nixpkgs
  # https://github.com/NixOS/nixpkgs/pull/142273#issuecomment-948225922
  # https://ertt.ca/nix/patch-nixpkgs/
  # https://github.com/NixOS/nix/issues/3920#issuecomment-681187597
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

  originPkgs = inputs.nixpkgs.legacyPackages.${system};

  nixpkgs = originPkgs.applyPatches {
    name = "nixpkgs-patched";
    src = inputs.nixpkgs;
    patches = map originPkgs.fetchpatch remoteNixpkgsPatches ++ localNixpkgsPatches;
  };

  nixosSystem = import (nixpkgs + "/nixos/lib/eval-config.nix");
  # Uncomment to use a Nixpkgs without (remote/local)NixpkgsPatches
  # nixosSystem = inputs.nixpkgs.lib.nixosSystem;

  overlay = _final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;

      config.allowUnfree = true;
    };

    # Needed for services.auto-cpufreq.enable
    inherit (p) auto-cpufreq;
  };

  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
    overlays = [ overlay ];
  };

  # inherit (nixpkgs) lib;
in
{
  nixos = nixosSystem {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser p;
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
