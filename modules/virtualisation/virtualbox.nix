{ lib, config, ... }:

let
  inherit (lib) mkEnableOption;

  cfg = config.local.virtualisation.virtualbox;
in
{
  options.local.virtualisation.virtualbox = {
    enable = mkEnableOption "VirtualBox";
    enableKvm = mkEnableOption "KVM support for VirtualBox";
  };

  config = lib.mkIf cfg.enable {
    # Virtual machine stuff
    virtualisation.virtualbox.host = {
      inherit (cfg) enable;
      inherit (cfg) enableKvm;
    };
  };
}
