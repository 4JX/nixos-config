# https://github.com/xddxdd/nixos-config/commit/aac53fe0ec712520309682509837ffc563c2af7b
# https://github.com/xddxdd/nixos-config/blob/3a86625d1b6fa594183728e06f956b47de67a966/nixos/hardware/hdr.nix#L5

# Threads:
# https://discuss.whatever.social/r/linux_gaming/comments/1im9m57/how_to_do_hdr_in_gnome/
# https://discuss.whatever.social/r/linux/comments/1im9l9r/how_to_do_hdr_in_gnome/
{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.ncfg.system.hdr;
in
{
  options.ncfg.system.hdr = {
    enable = lib.mkEnableOption "HDR support";
  };

  config = lib.mkIf cfg.enable {
    environment.variables = {
      # Used in MPV, probably elsewhere too
      ENABLE_HDR_WSI = "1";
    };

    # ENABLE_HDR_WSI=1 mpv --hwdec=auto-safe --vo=gpu-next --target-colorspace-hint --gpu-api=vulkan --gpu-context=waylandvk file
    hardware.graphics.extraPackages = [
      pkgs.vulkan-hdr-layer-kwin6
    ];
  };
}
