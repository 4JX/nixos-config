{ config, lib, primaryUser, pkgs, p, ... }:

# https://thewiki.moe/tutorials/mpv/
# https://kokomins.wordpress.com/2019/10/14/mpv-config-guide/

let
  cfg = config.ncfg.programs.video.mpv;

  externalFiles = {
    "shaders/SSimSuperRes.glsl" = {
      source = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b/raw/15d93440d0a24fc4b8770070be6a9fa2af6f200b/SSimSuperRes.glsl";
        sha256 = "sha256-qLJxFYQMYARSUEEbN14BiAACFyWK13butRckyXgVRg8=";
      };
    };
    "shaders/KrigBilateral.glsl" = {
      source = pkgs.fetchurl {
        url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/7c151e0af2281ae6657809be1f3c5efe0e325c38/KrigBilateral.glsl";
        sha256 = "sha256-uIbPX59nIHeHC9wa1Mv1nQartUusOgXaEHQyA95BST8=";
      };
    };
    "shaders/" = {
      source = p.anime4k;
      recursive = true;
    };
    "fonts/uosc_icons.otf" = {
      source = with pkgs.unstable.mpvScripts; "${uosc}/share/fonts/uosc_icons.otf";
    };
    "fonts/uosc_textures.ttf" = {
      source = with pkgs.unstable.mpvScripts; "${uosc}/share/fonts/uosc_textures.ttf";
    };
    "script-opts/thumbfast.conf" = {
      source = ./thumbfast.conf;
    };
    "script-opts/evafast.conf" = {
      source = ./evafast.conf;
    };
  };

  scriptsUnstable = with pkgs.unstable.mpvScripts; [ uosc autoload ];
  scriptsCustom = with p.mpvScripts; [ thumbfast betterChapters pauseWhenMinimize ]; # evafast

  # Escape character is "%"
  webSources = [ "HorribleSubs" "Erai%-raws" "SubsPlease" ];
  miniEncodeSources = [ "ASW" "DKB" "Judas" "Cleo" "Cerberus" "Reaktor" "Ember" "Nep%_Blanc" "Akihito" ];

  # Case insensitive filename match
  debandCond = names: builtins.concatStringsSep " or " (builtins.map (x: ''string.match(string.lower(p.filename), string.lower("${x}"))~=nil'') names);
in
{
  options.ncfg.programs.video.mpv.enable = lib.mkEnableOption "Enable mpv";

  config = lib.mkIf cfg.enable {


    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.mpv = {
        enable = cfg.enable;
        config = {
          #### General
          profile = "gpu-hq"; # Better scaling than default
          # gpu-api = "vulkan"; # Maybe better performance (Default: 3D311, Other: opengl)
          vo = "gpu"; # General purpose, customizable, GPU-accelerated video output driver. It supports extended scaling methods, dithering, color management, custom shaders, HDR, and more.
          # script-opts=ytdl_hook;-ytdl_path=yt;-dlp.exe
          cursor-autohide-fs-only = true;
          cursor-autohide = 100;
          fullscreen = "yes"; #Set to no if you don't want to start in fullscreen
          # target-prim = "dci-p3";

          #### UI
          keep-open = "yes"; # Do not close the program when finishing the last video (Default: no, Other: always (don't terminate or go to the next file))
          reset-on-next-file = "pause"; # Don't carry over the "pause" state when skipping files

          # window-scale=1 # Scale the floating window by this factor with respect to the video resolution
          save-position-on-quit = true;
          # autofit-larger = "1920x1080"; # Max window size. Can also be a % ("50%") relative to screen size.
          # autofit-smaller = "858x480"; # Min window size. Can also be a % ("50%") relative to screen size.

          osd-duration = 500; # Hide OSD text after x ms.
          # osd-font = "JetBrainsMono Nerd Font";
          # UOSC specific
          osc = "no"; # Disable the on screen controls
          osd-bar = "no"; # uosc provides its own seeking/volume indicators
          border = "no"; # uosc will draw its own window controls if the window border is disabled

          #### Video
          dither-depth = "auto";

          #### Shaders

          # SSimSuperRes -> General rescaler
          # KrigBilateral -> High quality chroma upscaler
          glsl-shaders = [ "~~/shaders/SSimSuperResMitchell.glsl" "~~/shaders/KrigBilateral.glsl" ];
          scale = "ewa_lanczossharp"; # Chroma upscale. (Default (gpu-hq): spline36)
          # dscale = "mitchell"; # Chroma downscale. (Default (gpu-hq): mitchell)
          # cscale = "spline36"; # Luma upscale (Less sensitive than chroma). (Default (gpu-hq): spline36)


          #### Screenshots
          screenshot-format = "png";
          screenshot-high-bit-depth = "yes";
          screenshot-png-compression = 9; # PNG compression level, higher is better but takes more CPU
          screenshot-directory = "~/Pictures/mpv";

          #### Subtitle Options
          demuxer-mkv-subtitle-preroll = "yes"; #try harder to show embedded soft subtitles when seeking somewhere
          sub-ass-vsfilter-blur-compat = "no"; #Scale \blur tags by video resolution instead of script resolution (enabled by default)
          sub-fix-timing = "no"; #Adjust subtitle timing is to remove minor gaps or overlaps between subtitles
          sub-auto = "fuzzy"; #Load all subs containing the media filename.

          #### Language Priority
          slang = "eng,en,enUS"; # Subtitles
          alang = "jpn,ja,jpn,eng,en"; # Audio
        };

        profiles = {
          "Web" = {
            profile-cond = debandCond webSources;
            deband = "yes";
          };

          "Mini-Encode" =
            {
              profile-cond = debandCond miniEncodeSources;
              deband = "yes";
            };
        };

        scripts = scriptsUnstable ++ scriptsCustom;

        bindings = (import ./an4k-bindings.nix { inherit p; });
      };

      xdg.configFile =
        lib.mapAttrs' (name: value: { name = "mpv/${name}"; value = value; }) externalFiles;

    };
  };
}


