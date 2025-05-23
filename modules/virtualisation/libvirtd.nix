{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.local.virtualisation.libvirtd;
in
{
  options.local.virtualisation.libvirtd.enable = lib.mkEnableOption "libvirtd";

  config = lib.mkIf cfg.enable {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          ovmf = {
            enable = true;
            # Required for Windows 11
            packages = [ pkgs.OVMFFull.fd ];
          };
          # Required for Windows 11
          swtpm.enable = true;
          # Run qemu as an unprivileged user
          runAsRoot = false;
        };
        onBoot = "ignore";
        onShutdown = "shutdown";
      };
    };
  };
}
