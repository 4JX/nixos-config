{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./fonts
    ./security
    ./shell
    ./flatpak.nix
    ./gnome-keyring.nix
    ./networkmanager.nix
    ./sound.nix
    ./power-management.nix
    ./systemd.nix
  ];

  config.assertions = [{
    assertion = config.ncfg.system.users != [ ];
    message =
      ''
        No users have been declared for the system.
        Consider setting `config.ncfg.system.users` in your configuration
      '';
  }];

  options.ncfg.system = {
    users = mkOption {
      type = with types; listOf str;
      default = [ "infinity" ];
      description = "A list of home-manager users on the system.";
    };
  };
}
