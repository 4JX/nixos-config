{ lib, config, pkgs, ... }:

let
  cfg = config.ncfg.system.flatpak;
in
{
  options.ncfg.system.flatpak.enable = lib.mkEnableOption "Flatpak";

  config = lib.mkIf
    cfg.enable
    {
      services.flatpak.enable = true;

      xdg.portal.enable = true;

      # https://github.com/NixOS/nixpkgs/issues/119433
      # https://github.com/accelbread/config-flake/blob/744196b43b93626025e5a2789c8700a5ec371aad/nix/nixosModules/bind-fonts-icons.nix#L9
      system.fsPackages = [ pkgs.bindfs ];
      fileSystems =
        let
          mkRoSymBind = path: {
            device = path;
            fsType = "fuse.bindfs";
            options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
          };
          aggregatedFonts = pkgs.buildEnv {
            name = "system-fonts";
            paths = config.fonts.packages;
            pathsToLink = [ "/share/fonts" ];
          };
        in
        {
          # Create an FHS mount to support flatpak host icons/fonts
          "/usr/share/icons" = mkRoSymBind (config.system.path + "/share/icons");
          "/usr/share/fonts" = mkRoSymBind (aggregatedFonts + "/share/fonts");
        };
    };
}
