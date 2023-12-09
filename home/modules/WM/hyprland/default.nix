{ inputs, lib, osConfig, pkgs, ... }:

let
  cfg = osConfig.ncfg.WM.hyprland;
in
{
  imports = [ ./config.nix ];

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.default;

      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
    };
  };
}
