{ lib, pkgs, ... }:

{

  specialisation = {
    external-display.configuration = ./multiple-displays;
    integrated-only.configuration = {
      system.nixos.tags = [ "integrated-only" ];
      hardware.nvidiaOptimus.disable = true;
    };
    gpu-passthrough.configuration = {
      system.nixos.tags = [ "gpu-passthrough" ];

      ncfg.virtualisation = {
        libvirtd.enable = true;

        vfio = {
          enable = true;
          blacklistNvidia = true;

          # 10de:24dd video
          # 10de:228b audio
          # 1c5c:174a storage
          pciIds = [ "10de:24dd" "10de:228b" "1c5c:174a" ];
        };

        looking-glass.enable = true;

        hugepages = {
          enable = false;
          defaultPageSize = "1G";
          pageSize = "1G";
          numPages = 16;
        };
      };

      environment.systemPackages = with pkgs; [
        virtmanager
        qemu
        OVMF
        pciutils
      ];
    };
  };
}
