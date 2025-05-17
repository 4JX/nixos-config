{
  config,
  lib,
  pkgs,
  ...
}:

# Config for looking-glass is handled on the home-manager side
let
  cfg = config.ncfg.virtualisation.looking-glass;
in
{
  options.ncfg.virtualisation.looking-glass = {
    enable = lib.mkEnableOption "the Looking Glass client";

    sharedMemoryFile = {
      create = lib.mkOption {
        default = true;
        type = lib.types.bool;
        description = "Automatically create a shared memory file for Looking Glass to use";
      };

      user = lib.mkOption {
        default = "";
        type = lib.types.str;
        description = "The owner of the shared memory file";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # If the file is to be automatically created it needs to have a non-empty user
        assertion = (!cfg.enable) || cfg.sharedMemoryFile.user != "";
        message = ''
          The shared memory file for looking glass needs an user to be specified.
          Consider setting `config.ncfg.virtualisation.looking-glass.sharedMemoryFile.user` in your configuration
        '';
      }
    ];

    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];

    ncfg.virtualisation.sharedMemoryFiles = lib.optionals cfg.sharedMemoryFile.create {
      looking-glass = {
        inherit (cfg.sharedMemoryFile) user;
        group = "qemu-libvirtd";
        mode = "666";
      };
    };
  };
}
