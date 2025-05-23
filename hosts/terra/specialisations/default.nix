{ pkgs, ... }:

{

  specialisation = {
    external-display.configuration = ./multiple-displays;
    gpu-passthrough.configuration = {
      system.nixos.tags = [ "gpu-passthrough" ];

      local.virtualisation = {
        libvirtd.enable = true;

        vfio = {
          enable = true;
          blacklistNvidia = true;

          # 10de:24dd video
          # 10de:228b audio
          # 1c5c:174a storage
          pciIds = [
            "10de:24dd"
            "10de:228b"
            "1c5c:174a"
          ];
        };

        looking-glass = {
          enable = true;
          sharedMemoryFile = {
            create = true;
            user = "infinity";
          };
        };

        hugepages = {
          enable = false;
          defaultPageSize = "1G";
          pageSize = "1G";
          numPages = 16;
        };
      };

      environment.systemPackages = with pkgs; [
        virt-manager
        qemu
        OVMF
        pciutils
      ];
    };
  };
}
