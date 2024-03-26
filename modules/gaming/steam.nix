{ lib, config, pkgs, inputs, self, ... }:

let
  cfg = config.ncfg.programs.gaming;
  p = self.packages.${pkgs.system};
in
{
  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      # Provided by nix-gaming
      extraCompatPackages = with p; [
        proton-ge-custom
        proton-ge-custom-621
      ];
    };

    hardware.steam-hardware.enable = true;
  };
}
