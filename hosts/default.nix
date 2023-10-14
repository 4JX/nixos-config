{ self, myLib, ... }:

let
  inherit (self) inputs;


  hm = inputs.home-manager.nixosModules.home-manager;
  hw = inputs.nixos-hardware.nixosModules;
  hypr = inputs.hyprland.nixosModules.default;

  nixosSystem = inputs.nixpkgs.lib.nixosSystem;

  theme = import ../theme.nix;

  commonArgs = { inherit inputs self myLib theme; };
in
{
  nixos =
    let
      primaryUser = "infinity";
    in
    nixosSystem {
      specialArgs = commonArgs // { inherit primaryUser; };

      modules = [
        {
          networking.hostName = "nixos";
        }
        hw.lenovo-legion-16ach6h-hybrid
        ./laptop

        # Common
        self.nixosModules
        hm
        {
          # Use the same pkgs as the global nixpkgs
          home-manager.useGlobalPkgs = true;
          # Install stuff to /etc/profiles
          home-manager.useUserPackages = true;
          imports = [
            ../home
          ];

          home-manager.extraSpecialArgs = {
            inherit primaryUser;
          };
        }
        hypr
      ];
    };
}
