{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.system.flatpak;
in
{
  options.ncfg.system.flatpak.enable = lib.mkEnableOption "Enable Flatpak";

  config = lib.mkIf
    cfg.enable
    {
      services.flatpak.enable = true;

      xdg.portal.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/119433
      # https://github.com/accelbread/config-flake/blob/951dfc729df4c95d44d7662ecc9cd7d6853d8285/nixos/common/flatpak-fonts.nix
      system.fsPackages = [ pkgs.bindfs ];
      fileSystems = lib.mapAttrs
        (_: v: v // {
          fsType = "fuse.bindfs";
          options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
        })
        {
          "/usr/share/icons".device = "/run/current-system/sw/share/icons";
          "/usr/share/fonts".device = pkgs.buildEnv
            {
              name = "system-fonts";
              paths = config.fonts.fonts;
              pathsToLink = [ "/share/fonts" ];
            } + "/share/fonts";
        };
    };
}
