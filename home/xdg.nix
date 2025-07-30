{ ... }:

let
  firefox = [ "firefox.desktop" ];
  mpv = [ "mpv.desktop" ];

  associations = {
    "application/x-extension-htm" = firefox;
    "application/x-extension-html" = firefox;
    "application/x-extension-shtml" = firefox;
    "application/x-extension-xht" = firefox;
    "application/x-extension-xhtml" = firefox;
    "application/xhtml+xml" = firefox;
    "text/html" = firefox;
    "x-scheme-handler/about" = firefox;
    "x-scheme-handler/http" = firefox;
    "x-scheme-handler/https" = firefox;
    "x-scheme-handler/unknown" = firefox;
    "x-scheme-handler/chrome" = firefox;
    "application/json" = firefox;
    "application/pdf" = firefox;

    # "audio/*" = mpv;
    "video/*" = mpv;

    "x-scheme-handler/msteams" = [ "teams-for-linux.desktop" ];
    "x-scheme-handler/discord" = [ "discord.desktop" ];
    "x-scheme-handler/spotify" = [ "spotify.desktop" ];
  };
in
{
  xdg = {
    enable = true;
    # userDirs = {
    #   enable = true;
    #   createDirectories = true;
    # };
    mimeApps = {
      enable = true;
      defaultApplications = associations;
    };
  };
}
