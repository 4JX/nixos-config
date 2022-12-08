{ lib, config, ... }:

let
  cfg = config.ncfg.virtualisation.libvirtd;
in
{
  options.ncfg.virtualisation.libvirtd.enable = lib.mkEnableOption "Enable libvirtd";

  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          ovmf.enable = true;
          # Run qemu as an unprivileged user
          runAsRoot = false;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };
    };
  };
}
