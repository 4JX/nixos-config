{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.programs.editors.vscodium;
in
{
  options.local.programs.editors.vscodium = {
    enable = lib.mkEnableOption "VSCodium";

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
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;

      # Extensions are managed through Settings Sync because it also syncs other stuff
      inherit (cfg) mutableExtensionsDir;
    };

    # Use the VSCode marketplace
    xdg.configFile = lib.mkIf cfg.useVSCodeMarketplace {
      "VSCodium/product.json".source = ./product.json;
    };
  };
}
