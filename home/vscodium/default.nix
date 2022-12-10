{ pkgs, config, lib, primaryUser, ... }:

let
  cfg = config.ncfg.home.programs.editors.vscodium;
in
{
  options.ncfg.home.programs.editors.vscodium = {
    enable = lib.mkEnableOption "Enable VSCodium";

    mutableExtensionsDir = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Allow manually downloading and installing extensions";
    };

    useVSCodeMarketplace = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Use the official VSCode marketplace instead of Open VSX";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;

        # Extensions are managed through Settings Sync
        mutableExtensionsDir = cfg.mutableExtensionsDir;
      };

      # Use the VSCode marketplace
      xdg.configFile = lib.mkIf cfg.useVSCodeMarketplace {
        "VSCodium/product.json".source = ./product.json;
      };
    };
  };
}
