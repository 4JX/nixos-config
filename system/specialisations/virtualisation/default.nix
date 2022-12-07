{ pkgs, config, ... }:
let
  cfg = config.cfg;
in
{
  imports = [ ./virtualisation.nix ];

  boot.kernelParams = [ "amd_iommu=on" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
  boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
  # 10de:24dd video
  # 10de:228b audio
  # 1c5c:174a storage
  boot.extraModprobeConfig = "options vfio-pci ids=10de:24dd,10de:228b,1c5c:174a";

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

    sharedMemoryFiles = {
      looking-glass = {
        user = cfg.user;
        group = "qemu-libvirtd";
        mode = "666";
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
    virtmanager
    qemu
    OVMF
    pciutils
    # Use B6-rc1
    (looking-glass-client.overrideAttrs
      (final: prev: rec {
        pname = "looking-glass-client";
        version = "B6-rc1";

        src = fetchFromGitHub {
          owner = "gnif";
          repo = "LookingGlass";
          rev = version;
          sha256 = "sha256-FZjwLY2XtPGhwc/GyAAH2jvFOp61lSqXqXjz0UBr7uw=";
          fetchSubmodules = true;
        };

        buildInputs = with pkgs; prev.buildInputs ++ [ pipewire libpulseaudio libsamplerate ];
      }))
  ];

  environment.etc."SSDT1.dat".source = ./SSDT1.dat;

  home-manager.users.${cfg.user} = { pkgs, config, ... }: {
    xdg.configFile."looking-glass/client.ini".source = ./lg-config.ini;
  };
}
