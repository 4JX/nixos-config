{
  description = "Personal NixOS configuration";

  outputs =
    inputs@{ self, treefmt-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      myLib = import ./lib inputs;

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./fmt.nix;
    in
    {
      nixosConfigurations = import ./hosts {
        inherit self myLib;
      };

      formatter.${system} = treefmtEval.config.build.wrapper;

      packages.${system} = pkgs.callPackage ./pkgs { inherit inputs system; };

      checks.${system} = {
        formatting = treefmtEval.config.build.check self;
      };

      devShells.${system}.docs = import ./mkDocs.nix { inherit pkgs; };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-ckb-next-qt6.url = "github:4JX/nixpkgs/ckb-next-qt6-pre";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    # nixos-hardware.url = "github:4JX/nixos-hardware";

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

    # Makes command-not-found work
    programsdb = {
      url = "github:wamserma/flake-programs-sqlite";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Alternative database for nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Are you paranoid enough yet?
    arkenfox-nixos = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      # optional, not necessary for the module
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Basic theme-ing integration, might consider stylix
    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Project wide formatting
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Home server stuff
    home-server = {
      # git+ssh://git@[host]/[owner]/[repo]?ref=[branch]
      url = "git+ssh://git@github.com/4JX/nixos-lab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # -- Extra packages --
    legion-kb-rgb = {
      url = "github:4JX/L5P-Keyboard-RGB";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
