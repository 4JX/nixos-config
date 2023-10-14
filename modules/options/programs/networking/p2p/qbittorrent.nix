{ primaryUser, config, lib, ... }:

let
  cfg = config.ncfg.programs.networking.p2p.qBittorrent;
in
{
  options.ncfg.programs.networking.p2p.qBittorrent = {
    enable = lib.mkEnableOption "qBittorrent";
    devices = lib.mkOption {
      default = { };
      type = lib.types.attrs;
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = ''
        The port that is used for peers to connect
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      home.packages = with pkgs; [
        qbittorrent
      ];
    };
  };
}
