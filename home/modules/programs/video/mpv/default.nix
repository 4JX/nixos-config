{
  config,
  lib,
  pkgs,
  self,
  osConfig,
  ...
}:

# https://thewiki.moe/tutorials/mpv/
# https://thewiki.moe/guides/playback/
# https://kokomins.wordpress.com/2019/10/14/mpv-config-guide/
# https://artoriuz.github.io/blog/mpv_upscaling.html
# https://kohana.fi/article/mpv-for-anime
# https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/

let
  cfg = config.local.programs.video.mpv;

  externalFiles = {
    "fonts/uosc_icons.otf" = {
      source = with pkgs.mpvScripts; "${uosc}/share/fonts/uosc_icons.otf";
    };
    "fonts/uosc_textures.ttf" = {
      source = with pkgs.mpvScripts; "${uosc}/share/fonts/uosc_textures.ttf";
    };
    "script-opts/thumbfast.conf" = {
      source = ./thumbfast.conf;
    };
    "script-opts/evafast.conf" = {
      source = ./evafast.conf;
    };
    "script-opts/uosc.conf" = {
      source = ./uosc.conf;
    };
  };

  p = self.packages.${pkgs.system};

  scriptsPkgs = with pkgs.mpvScripts; [
    uosc
    thumbfast
  ]; # autoload
  scriptsCustom = with p.mpv.mpvScripts; [
    betterChapters
    pauseWhenMinimize
  ]; # evafast mpv-jellyfin
  scripts = scriptsPkgs ++ scriptsCustom;

  # Escape character is "%"
  webSources = [
    "HorribleSubs"
    "Erai%-raws"
    "SubsPlease"
    "Tsundere%-Raws"
  ];
  miniEncodeSources = [
    "ASW"
    "DKB"
    "Judas"
    "Cleo"
    "Cerberus"
    "Reaktor"
    "Ember"
    "Nep%_Blanc"
    "Akihito"
  ];

  # Case insensitive filename match
  debandCond =
    names:
    builtins.concatStringsSep " or " (
      builtins.map (x: ''string.match(string.lower(p.filename), string.lower("${x}"))~=nil'') names
    );
  # HDR enabled on system?
  hdrEnabled = osConfig.local.system.hdr.enable;
in
{
  imports = [ ./jellyfin-shim ];

  options.local.programs.video.mpv.enable = lib.mkEnableOption "MPV";

  config = lib.mkIf cfg.enable {
    programs.mpv = {
      inherit (cfg) enable;
      # https://github.com/haasn/libplacebo/issues/333
      package =
        lib.warn "Using patched mpv https://github.com/haasn/libplacebo/issues/333"
          pkgs.mpv-unwrapped.wrapper
          {
            inherit scripts;

            mpv = pkgs.mpv-unwrapped.override {
              libplacebo = pkgs.libplacebo.overrideAttrs (old: {
                src = pkgs.fetchFromGitHub {
                  owner = "haasn";
                  repo = "libplacebo";
                  rev = "3662b1f5d5a721f31cbf6c0ad090ac2345834cab";
                  hash = "sha256-M9Z/Ip+pJYqEWA6BjptVdyX+tDZx8lb+EraqqzAhX6E=";
                };
              });

            };
          };

      config = {
        #### UI
        fullscreen = "yes"; # Start in fullscreen by default
        keep-open = "yes"; # Do not close the program when finishing the last video (Default: no, Other: always (don't terminate or go to the next file))
        reset-on-next-file = "pause"; # Don't carry over the "pause" state when skipping files
        # window-scale=1 # Scale the floating window by this factor with respect to the video resolution
        save-position-on-quit = true;
        autofit-larger = "75%"; # Max window size. Can also be a % ("50%") relative to screen size.
        autofit-smaller = "858x480"; # Min window size. Can also be a % ("50%") relative to screen size.

        cursor-autohide-fs-only = true; # Hide the cursor only in fullscreen
        cursor-autohide = 100; # Quickly hide the cursor

        osd-duration = 500; # Hide OSD text after x ms.
        osd-font = "JetBrainsMono Nerd Font";

        # UOSC specific
        osc = "no"; # Disable the on screen controls
        osd-bar = "no"; # uosc provides its own seeking/volume indicators
        # border = "no"; # uosc will draw its own window controls if the window border is disabled

        #### Video
        # https://github.com/mpv-player/mpv/blob/c3f93f5fdd33ada85e700bf8bad7d70f6739eed4/etc/builtin.conf#L43
        profile = "high-quality"; # Better scaling than default

        # Defaults to "no", generally not needed but can be set to "auto" to use nvenc (faster but power hungry if not plugged in)
        hwdec = "auto-safe";

        # Best performance of the bunch (Default: 3D311, Other: opengl)
        gpu-api = "vulkan";
        # fbo-format = "rgba16hf";

        # GPU-accelerated video output driver. gpu-next also exists but is somewhat questionable ATM.
        vo = "gpu-next";

        dither-depth = "auto"; # Leave software dither enabled just in case

        # icc-profile-auto = true; # Probably not really needed since the entire screen is calibrated through a profile
        # target-prim = "dci-p3"; # Cap the colors at the specified gamut to fix oversaturation

        #### Shaders
        # Defaults for everyday use, heavier shaders are left to bindings
        glsl-shaders =
          with p.mpv.shaders;
          builtins.concatStringsSep ":" [
            SSimSuperRes # Luma upscaler
            SSimDownscaler # Luma downscaler
            KrigBilateral # Chroma up+down
          ];
        scale = "ewa_lanczossharp"; # Luma upscale. (Default (high-quality): spline36)
        # dscale = "lanczos"; # Overkill, spline36/mitchell would be fine. Luma downscale. (Default (high-quality): mitchell)
        cscale = "ewa_lanczossharp"; # Chroma upscale (Less sensitive than luma). (Default (high-quality): ewa_lanczossharp)
        linear-downscaling = "no"; # Overrides the high-quality option, needed for SSimDownscaler
        correct-downscaling = "yes";

        #### Screenshots
        screenshot-format = "png";
        screenshot-high-bit-depth = "yes";
        screenshot-png-compression = 9; # PNG compression level, higher is better but takes more CPU
        screenshot-directory = "~/Pictures/mpv";

        #### Subtitle Options
        demuxer-mkv-subtitle-preroll = "yes"; # try harder to show embedded soft subtitles when seeking somewhere
        sub-fix-timing = "no"; # Adjust subtitle timing is to remove minor gaps or overlaps between subtitles
        sub-auto = "fuzzy"; # Load all subs containing the media filename.

        #### Language Priority
        slang = "eng,en,enUS"; # Subtitles
        alang = "jpn,ja,jpn,eng,en"; # Audio
      };
      # // (lib.optionalAttrs hdrEnabled {
      #   gpu-context = "waylandvk"; # Default "auto". Set to "help" to see possible modes
      #   target-colorspace-hint = "auto";
      #   hdr-compute-peak = "yes";
      # });

      profiles = {
        # Configure HDR if enabled system-wide
        # This currently only works with wayland (tested)
        "HDR" =
          if hdrEnabled then
            {
              profile-cond = ''p["video-params/gamma"] == "pq"'';
              gpu-context = "waylandvk"; # Default "auto". Set to "help" to see possible modes
              target-colorspace-hint = "yes";
              hdr-compute-peak = "yes";
            }
          else
            {
              profile-cond = ''p["video-params/gamma"] == "pq"'';
              tone-mapping = "bt.2446a"; # Default: spline. A little too dark for my taste
            };

        "Web" = {
          profile-cond = debandCond webSources;
          deband = "yes";
          deband-iterations = 2; # Range 1-16. Higher = better quality but more GPU usage. >5 is redundant.
          deband-threshold = 35; # Range 0-4096. Deband strength.
          deband-range = 20; # Range 1-64. Range of deband. Too high may destroy details.
          deband-grain = 5; # Range 0-4096. Inject grain to cover up bad banding, higher value needed for poor sources.
        };

        "Mini-Encode" = {
          profile-cond = debandCond miniEncodeSources;
          deband = "yes";
          deband-iterations = 2; # Range 1-16. Higher = better quality but more GPU usage. >5 is redundant.
          deband-threshold = 35; # Range 0-4096. Deband strength.
          deband-range = 20; # Range 1-64. Range of deband. Too high may destroy details.
          deband-grain = 5; # Range 0-4096. Inject grain to cover up bad banding, higher value needed for poor sources.
        };
      };

      # TODO: Re-enable and remove package declaration
      # inherit scripts;

      bindings = import ./bindings.nix { inherit p pkgs; };
    };

    xdg.configFile = lib.mapAttrs' (name: value: {
      name = "mpv/${name}";
      inherit value;
    }) externalFiles;
  };
}
