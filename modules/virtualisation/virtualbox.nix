{ lib, config, ... }:

let
  inherit (lib) versionAtLeast optionals mkEnableOption;
  kernelVersion = config.boot.kernelPackages.kernel.version;
  is612orLater = versionAtLeast kernelVersion "6.12";

  cfg = config.ncfg.virtualisation.virtualbox;
in
{
  options.ncfg.virtualisation.virtualbox = {
    enable = mkEnableOption "VirtualBox";
    enableKvm = mkEnableOption "KVM support for VirtualBox";
  };

  config = lib.mkIf cfg.enable {
    # Virtual machine stuff
    virtualisation.virtualbox.host = {
      inherit (cfg) enable;
      inherit (cfg) enableKvm;
    };

    # Workaround for https://github.com/NixOS/nixpkgs/issues/363887
    boot.kernelParams = optionals (is612orLater && !cfg.enableKvm) [ "kvm.enable_virt_at_load=0" ];
  };
}
