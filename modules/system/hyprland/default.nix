{ lib, config, primaryUser, ... }:

let
  cfg = config.ncfg.system.hyprland;
in
{
  options.ncfg.system.hyprland.enable = lib.mkEnableOption "hyprland";

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    programs.hyprland = {
      enable = true;
      enableNvidiaPatches = true;
    };

    home-manager.users.${primaryUser} = { pkgs, ... }: {
      xdg.configFile."hyprland.conf" = {
        text = import ./config.nix { };
        target = "hypr/hyprland.conf";
        onChange = "${pkgs.hyprland}/bin/hyprctl reload";
      };
    };
  };
}
