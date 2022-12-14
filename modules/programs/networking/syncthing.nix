{ primaryUser, config, lib, ... }:

let
  cfg = config.ncfg.programs.networking.syncthing;
in
{
  options.ncfg.programs.networking.syncthing = {
    enable = lib.mkEnableOption "Enable Syncthing";
    devices = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
    folders = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = primaryUser;
      dataDir = "/home/${primaryUser}"; # configDir is set automatically from dataDir
      openDefaultPorts = true;
      group = "users";
      overrideFolders = true;
      overrideDevices = true;

      devices = cfg.devices;
      folders = cfg.folders;

    };

    home-manager.users.${primaryUser} = { pkgs, ... }: {

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
