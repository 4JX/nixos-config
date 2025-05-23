{ lib, config, ... }:

let
  inherit (lib) mkOption types;
in
{
  imports = [
    ./dns
    ./environment
    ./fonts
    ./power-management
    ./security
    ./programs
    ./flatpak.nix
    ./gnome-keyring.nix
    ./hdr.nix
    ./sound.nix
    ./systemd.nix
  ];

  config.assertions = [
    {
      assertion = config.local.system.users != [ ];
      message = ''
        No users have been declared for the system.
        Consider setting `config.local.system.users` in your configuration
      '';
    }
  ];

  options.local.system = {
    users = mkOption {
      type = with types; listOf str;
      default = [ "infinity" ];
      description = "A list of home-manager users on the system.";
    };
  };
}
