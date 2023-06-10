inputs@{ nixpkgs, home-manager, nixos-hardware, hyprland, ... }:

let
  primaryUser = "infinity";

  system = "x86_64-linux"; # System architecture

  # An instance of Nixpkgs used solely for instantiating the custom packages with callPackage
  pkgsCall = import nixpkgs {
    inherit system;

    config.allowUnfree = true;
  };

  myLib = pkgsCall.callPackage ../lib { };

  # Collection of custom packages
  p = {
    legion-kb-rgb = inputs.legion-kb-rgb.packages.${system}.wrapped;
  } // (pkgsCall.callPackage ../pkgs { inherit myLib; });


  overlay = _final: _prev: {
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

    #! TODO: Remove these as soon as possible
    config.permittedInsecurePackages = [
      # Github-desktop
      "openssl-1.1.1u"
    ];
  };

  # inherit (nixpkgs) lib;
in
{
  inherit (patched) nixpkgs nixosSystem;

  cfg = {
    inherit system pkgs;

    specialArgs =
      {
        inherit primaryUser p myLib;
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

        home-manager.extraSpecialArgs = {
          inherit primaryUser;
        };
      }
      hyprland.nixosModules.default
      ./common.nix
      ./laptop
    ];
  };
}
