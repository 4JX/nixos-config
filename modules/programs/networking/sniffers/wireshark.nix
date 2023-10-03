{ primaryUser, config, lib, pkgs, ... }:

let
  cfg = config.ncfg.programs.networking.p2p.qBittorrent;
in
{
  options.ncfg.programs.networking.sniffers.wireshark = {
    enable = lib.mkEnableOption "Wireshark";
  };

  config = lib.mkIf cfg.enable {

    users.users.${primaryUser} = {
      extraGroups = [ "wireshark" ];
    };

    programs = {
      wireshark = {
        enable = true;
        package = pkgs.wireshark;
      };
    };

  };
}
