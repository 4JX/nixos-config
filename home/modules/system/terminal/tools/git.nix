{ config, lib, ... }:

let
  cfg = config.local.programs.git;
in
{
  options.local.programs.git = {
    enable = lib.mkEnableOption "git" // {
      enable = true;
    };
  };
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      extraConfig = {
        diff.colorMoved = "default";
        pull.rebase = true;
        push.autoSetupRemote = true;
      };

      delta.enable = true;
      # difftastic = {
      #   enable = true;
      #   display = "inline";
      # };
    };
  };
}
