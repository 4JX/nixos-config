{ config, lib, pkgs, mainUser, ... }:

let
  cfg = config.ncfg.virtualisation.looking-glass;
in
{
  options.ncfg.virtualisation.looking-glass = {
    enable = lib.mkEnableOption "the Looking Glass client";

    createSharedMemoryFile = lib.mkOption {
      default = cfg.enable;
      type = lib.types.bool;
      description = "Automatically create a shared memory file for Looking Glass to use";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    home-manager.users.${mainUser} = _: {
      xdg.configFile."looking-glass/client.ini".text = ''
        [input]
        # Right Control, see https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
        escapeKey=97
      '';
    };


    ncfg.virtualisation.sharedMemoryFiles = lib.optionals cfg.createSharedMemoryFile {
      looking-glass = {
        user = mainUser;
        group = "qemu-libvirtd";
        mode = "666";
      };
    };
  };
}