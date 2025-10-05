{ pkgs, ... }:

{
  # nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    btop
    iftop
    dig
    killall
    eza
    bat
    efibootmgr
    # nvtopPackages.full
    (inxi.override { withRecommends = true; }) # inxi -Fazy
    ripgrep # Faster grep
    ripgrep-all # Wrapper around ripgrep for convenience universal searching across a ton of filetypes
    fd # Better find
    exiftool # Metadata about various files

    # Disk tools
    smartmontools
    iotop
    fatrace
    lsof

    # Nix stuffs
    nil # Nix language server
    nixd # Another nix language server
    # nixpkgs-fmt
    nixfmt-rfc-style
    nixos-option
    deadnix
    statix
    nix-tree # Scan current system / derivations for what-why-how depends
    nixpkgs-review # For nixpkgs PRs
  ];
}
