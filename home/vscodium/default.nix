{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    # Extensions are managed through Settings Sync
    mutableExtensionsDir = true;
  };

  # Use the VSCode marketplace
  xdg.configFile."VSCodium/product.json".source = ./product.json;
}
