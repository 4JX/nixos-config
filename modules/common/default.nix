{ lib, pkgs, ... }:

{
  imports = [
    ./always-set.nix
  ];

  time.timeZone = lib.mkDefault "Europe/Madrid";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  console = {
    font = lib.mkDefault "Lat2-Terminus16";
    keyMap = lib.mkDefault "es";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    btop
    iftop
    killall
    eza
    bat
    cmake
    gcc
    efibootmgr
    nvtop
    (inxi.override
      { withRecommends = true; }) # inxi -Fazy
    ripgrep # Faster grep
    # FIXME: https://github.com/NixOS/nixpkgs/issues/250306
    # ripgrep-all # Wrapper around ripgrep for convenience universal searching across a ton of filetypes
    fd # Better find

    # Nix stuffs
    nil # Nix language server
    nixpkgs-fmt
    nixos-option
    deadnix
    statix
    nix-tree # Scan current system / derivations for what-why-how depends
  ];

  ncfg = {
    system = {
      fonts = {
        enableCommonFonts = true;
      };
      gnome-keyring.enable = true;
      networkmanager.enable = true;
      shell = {
        zsh = {
          enable = true;
          shellAliases = with pkgs; {
            update-config = "nixos-rebuild --use-remote-sudo switch";
            eza = "${eza}/bin/exa --icons";
          };
        };
        starship = {
          enable = true;
          enableZshIntegration = true;
        };
        kitty.enable = true;
      };
    };
  };
}
