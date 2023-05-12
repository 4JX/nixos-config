{ lib, config, primaryUser, ... }:

let
  cfg = config.ncfg.system.hyprland;
in
{
  options.ncfg.system.hyprland.enable = lib.mkEnableOption "Enable hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      nvidiaPatches = true;
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
