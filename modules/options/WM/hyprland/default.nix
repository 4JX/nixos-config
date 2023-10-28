{ inputs, lib, config, pkgs, ... }:

let
  cfg = config.ncfg.WM.hyprland;
in
{
  options.ncfg.WM.hyprland.enable = lib.mkEnableOption "hyprland";

  # Disables Nixpkgs Hyprland module to avoid conflicts
  # disabledModules = [ "programs/hyprland.nix" ];

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    # Should probably just gut out the relevant options from here but eh
    programs.hyprland = {
      enable = true;
      # Because I currently use upstream hyprland
      portalPackage = inputs.xdg-portal-hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
  };
}
