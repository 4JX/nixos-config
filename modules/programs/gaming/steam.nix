{
  lib,
  config,
  pkgs,
  self,
  ...
}:

let
  cfg = config.local.programs.gaming;
  p = self.packages.${pkgs.system};
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      extraCompatPackages = [
        pkgs.proton-ge-bin
        p.proton-ge-bin-621-2
      ];
    };

    hardware.steam-hardware.enable = true;
  };
}
