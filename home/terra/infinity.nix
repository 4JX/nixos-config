{
  pkgs,
  homeFiles,
  self,
  ...
}:
let
  p = self.packages.${pkgs.system};
in
{
  imports = [
    ../modules
    # ../xdg.nix
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";

  local = {
    DE.gnome.dashMonitorElements = ''
      {
        "GSM-210MATWT8S05":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],
        "CSO-0x00000000":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"centerMonitor"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]
      }
    '';

    programs = {
      audio.easyeffects = {
        enable = true;
        outputPresets = {
          # https://github.com/wwmm/easyeffects/wiki/Community-Presets
          # Based on https://gist.github.com/sebastian-de/648555c1233fdc6688c0a224fc2fca7e
          "Legion 5 Pro" = homeFiles + /easyeffects/L5P.json;
          "DT880" = homeFiles + /easyeffects/DT880.json;
          "Sony WH-CH720N" = homeFiles + /easyeffects/Sony_WH-CH720N.json;
        };
      };

      browsers.firefox = {
        enable = true;
      };

      editors = {
        vscodium = {
          enable = true;
          mutableExtensionsDir = true;
          useVSCodeMarketplace = true;
        };
      };

      misc = {
        screenshot-ocr = {
          enable = true;
          languages = [
            "eng"
            "spa"
          ];
        };
      };

      office = {
        libreoffice.enable = true;
        teams-for-linux.enable = true;
      };

      video = {
        mpv = {
          enable = true;
          jellyfin-mpv-shim.enable = true;
        };
      };
    };
  };

  home.packages = with pkgs; [
    kdePackages.kate
    keepassxc
    github-desktop
    spotify
    kdePackages.ark
    gh # Github CLI
    # jetbrains.clion # FIXME: https://github.com/NixOS/nixpkgs/pull/304223
    android-studio-full
    # handbrake
    vokoscreen-ng
    peek
    scrcpy
    tor-browser-bundle-bin
    arandr
    obsidian
    node2nix
    cyberchef
    # element-desktop # fails via insecure jitsi-meet-1.0.8043
    figma-linux
    quassel
    p.portmaster
    dbeaver-bin
    libsForQt5.okular
    qbittorrent
    openrgb
    # To be used along with the kernel module specified in the boot option
    # Adds legion_cli legion_gui to PATH
    lenovo-legion
    endeavour # TODO app that integrates with the GNOME todo extension

    # JOSM
    josm
    # JOSM Catastro
    (
      (josm.overrideAttrs (old: {
        name = "${old.pname}-catastro-${old.version}";

        # Direct replacement wont work because of mkWrapper
        # -e 's/Exec=josm %U/Exec=env JAVA_OPTS="-Djosm.home=JOSM-catastro" josm %U/' \
        # chmod +w $out/share/applications
        installPhase = ''
          ${old.installPhase}

          mv $out/bin/josm $out/bin/josm-catastro

          chmod +w $out/share/applications
          mv $out/share/applications/org.openstreetmap.josm.desktop $out/share/applications/org.openstreetmap.josm-catastro.desktop
          sed -e 's/Name=JOSM/Name=JOSM Catastro/' \
              -e 's/Exec=josm %U/Exec=josm-catastro %U/' \
              $out/share/applications/org.openstreetmap.josm-catastro.desktop -i
        '';
      })).override
      {
        # First two are from the package
        extraJavaOpts = "-Djosm.restart=true -Djava.net.useSystemProxies=true -Djosm.home=JOSM-catastro";
      }
    )

    fractal
    kdePackages.filelight

    pinta # paint.net but linux? Not as complex as GIMP

    # Filesharing but easy
    localsend

    p.proton-mail-export

    # Diff viewer
    meld

    jetbrains.idea-community
  ];
}
