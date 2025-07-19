{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.local.programs.office.teams-for-linux;
in
{
  options.local.programs.office.teams-for-linux = {
    enable = lib.mkEnableOption "Microsoft Teams";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      teams-for-linux
      # https://github.com/leiserfg/nix-config/blob/a0a4b6f0a81d4c897649014194680d03770135de/home/leiserfg/common.nix#L222C5-L233C7
      (makeDesktopItem {
        name = "teams-for-linux-call";
        exec = "teams-for-linux %U";
        icon = "teams-for-linux";
        desktopName = "Microsoft Teams for Linux";
        categories = [
          "Network"
          "InstantMessaging"
          "Chat"
        ];
        # TODO: Perhaps use the xdg home-manager module instead?
        mimeTypes = [ "x-scheme-handler/msteams" ];
      })
    ];
  };
}
