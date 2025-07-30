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
  # Used in the XDG module
  options.local.programs.office.teams-for-linux = {
    enable = lib.mkEnableOption "Microsoft Teams";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      teams-for-linux
    ];
  };
}
