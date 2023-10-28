{ inputs, lib, config, pkgs, ... }:

let
  cfg = config.ncfg.WM.hyprland;
  hyprland = inputs.hyprland.packages.${pkgs.system}.default;
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

    # http://wiki.hyprland.org/FAQ/#how-do-i-make-hyprland-draw-as-little-power-as-possible-on-my-laptop
    ncfg.system.power-management =
      let
        mkHyprctlCommand = action: value: pkgs.writeShellApplication {
          name = "${action}_heavy_effects";
          runtimeInputs = [ hyprland ];

          text =
            ''
              # writeShellApplication is a little too sane with this for this case
              set +o nounset

              if [[ -z ${"\${HYPRLAND_INSTANCE_SIGNATURE}"} ]];
              then
                exit 0
              else
                hyprctl --batch 'keyword decoration:drop_shadow ${value} ; keyword animations:enabled ${value}'
              fi
            '';
        };

        enable = mkHyprctlCommand "enable" "1";
        disable = mkHyprctlCommand "disable" "0";
      in
      {
        onPlugged = [ enable ];
        onUnplugged = [ disable ];
      };
  };
}
    

