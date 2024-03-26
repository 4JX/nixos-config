{ pkgs, ... }:

{
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
    nvtopPackages.full
    (inxi.override
      { withRecommends = true; }) # inxi -Fazy
    ripgrep # Faster grep
    # FIXME: https://github.com/NixOS/nixpkgs/issues/250306
    # ripgrep-all # Wrapper around ripgrep for convenience universal searching across a ton of filetypes
    fd # Better find
    exiftool # Metadata about various files

    # Nix stuffs
    nil # Nix language server
    nixpkgs-fmt
    nixos-option
    deadnix
    statix
    nix-tree # Scan current system / derivations for what-why-how depends
  ];
}
