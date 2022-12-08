{ config, lib, pkgs, primaryUser, ... }:

let
  cfg = config.ncfg.virtualisation.looking-glass;
in
{
  options.ncfg.virtualisation.looking-glass = {
    enable = lib.mkEnableOption "Enable the Looking Glass client";

    createSharedMemoryFile = lib.mkOption {
      default = cfg.enable;
      type = lib.types.bool;
      description = "Automatically create a shared memory file for Looking Glass to use";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      # Use B6-rc1
      (looking-glass-client.overrideAttrs
        (final: prev: rec {
          pname = "looking-glass-client";
          version = "B6-rc1";

          src = fetchFromGitHub {
            owner = "gnif";
            repo = "LookingGlass";
            rev = version;
            sha256 = "sha256-FZjwLY2XtPGhwc/GyAAH2jvFOp61lSqXqXjz0UBr7uw=";
            fetchSubmodules = true;
          };

          buildInputs = with pkgs; prev.buildInputs ++ [ pipewire libpulseaudio libsamplerate ];
        }))
    ];

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      xdg.configFile."looking-glass/client.ini".text = ''
        [input]
        # Right Control, see https://github.com/torvalds/linux/blob/master/include/uapi/linux/input-event-codes.h
        escapeKey=97
      '';
    };


    ncfg.virtualisation.sharedMemoryFiles = lib.optionals cfg.createSharedMemoryFile {
      looking-glass = {
        user = primaryUser;
        group = "qemu-libvirtd";
        mode = "666";
      };
    };
  };
}
