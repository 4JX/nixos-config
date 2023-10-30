{ mainUser, lib, config, inputs, self, theme, myLib, ... }:

let
  hostName = config.networking.hostName;

  userHomes = lib.genAttrs config.ncfg.system.users (name: ./${hostName}/${name}.nix);

  homeFiles = ./files;
in
{
  home-manager = {
    # Use the same nixpkgs instance as the global nixpkgs
    useGlobalPkgs = true;
    # Install stuff to /etc/profiles
    useUserPackages = true;
    extraSpecialArgs = { inherit mainUser inputs self homeFiles theme myLib; };
    users = userHomes;
  };

}

