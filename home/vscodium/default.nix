{ pkgs, ... }: {
  #home.packages = with pkgs; [ vscodium ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    # Extensions are managed through Settings Sync
    mutableExtensionsDir = true;
  };

  xdg.configFile."VSCodium/product.json".source = ./product.json;
}
