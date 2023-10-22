{ pkgs, ... }:

{
  # https://github.com/NixOS/nixpkgs/issues/168484#issuecomment-1501080778 Fixes crash when figma-linux tries to save files
  xdg.systemDirs.data = with pkgs; [
    "${gtk3}/share/gsettings-schemas/gtk+3-${gtk3.version}"
    "${gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${gsettings-desktop-schemas.version}"
  ];
}
