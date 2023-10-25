{ lib, config, pkgs, mainUser, inputs, self, ... }:

let
  cfg = config.ncfg.programs.games.steam;
  p = self.packages.${pkgs.system};
in
{
  # https://github.com/NixOS/nixpkgs/pull/189398
  # https://github.com/NixOS/nixpkgs/issues/73323
  # https://github.com/Shawn8901/nix-configuration/blob/c8e2c749c2c43e7637e5a2ccb8e63d4c75fabc9d/modules/nixos/steam-compat-tools.nix
  imports = [ inputs.nix-gaming.nixosModules.steamCompat ];

  options.ncfg.programs.games.steam = with lib; {
    enable = mkEnableOption "Steam";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;

      # Provided by nix-gaming
      extraCompatPackages = with p; [
        proton-ge-custom
        proton-ge-custom-621
      ];
    };

    hardware.steam-hardware.enable = true;

    # Replace the desktop file if offload is enabled (force use nvidia-offload)
    # home-manager.users.${mainUser} = lib.mkIf config.hardware.nvidia.prime.offload.enable {
    #   home.file.".local/share/applications/steam.desktop".source = ./steam.desktop;
    # };

    home-manager.users.${mainUser} = {
      home.packages = with pkgs; [ gamemode gamescope ];
    };
  };
}
