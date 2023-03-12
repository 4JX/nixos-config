{ lib, config, pkgs, primaryUser, ... }:

let
  cfg = config.ncfg.programs.games.steam;
in
{
  options.ncfg.programs.games.steam = {
    enable = lib.mkEnableOption "Enable Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      # package = pkgs.steam.override {
      #   extraPkgs = pkgs: with pkgs; [
      #     gamescope
      #     mangohud
      #   ];
      # };
      remotePlay.openFirewall = true;
    };

    hardware.steam-hardware.enable = true;

    # Replace the desktop file if offload is enabled (force use nvidia-offload)
    # home-manager.users.${primaryUser} = lib.mkIf config.hardware.nvidia.prime.offload.enable {
    #   home.file.".local/share/applications/steam.desktop".source = ./steam.desktop;
    # };

    home-manager.users.${primaryUser} = {
      home.packages = with pkgs; [ gamemode mangohud gamescope ];

      # programs.mangohud.enable = true;
    };

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${pkgs.proton-ge-custom}";
    };
  };
}
