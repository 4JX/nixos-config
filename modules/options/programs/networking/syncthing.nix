{ mainUser, config, lib, ... }:

let
  cfg = config.ncfg.programs.networking.syncthing;
in
{
  options.ncfg.programs.networking.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
    settings = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = mainUser;
      dataDir = "/home/${mainUser}"; # configDir is set automatically from dataDir
      openDefaultPorts = true;
      group = "users";
      overrideFolders = true;
      overrideDevices = true;

      inherit (cfg) settings;
    };

    home-manager.users.${mainUser} = { pkgs, ... }: {

      home.packages = with pkgs; [
        # Not working, https://github.com/NixOS/nixpkgs/issues/199596
        syncthingtray
      ];

      # services.syncthing.tray = {
      #   package = pkgs.syncthingtray;
      #   enable = true;
      #   command = "${pkgs.syncthingtray} --wait";
      # };
    };
  };
}
