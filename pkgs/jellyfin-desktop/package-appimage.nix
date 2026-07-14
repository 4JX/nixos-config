{
  appimageTools,
  fetchurl,
  lib,
  runCommand,
  unzip,
}:

let
  pname = "jellyfin-desktop";
  version = "3.0.0-dev+225af09";

  artifact = fetchurl {
    url = "https://nightly.link/jellyfin/jellyfin-desktop/workflows/build-linux-appimage/main/linux-appimage-x86_64.zip";
    hash = "sha256-SulLV5WNPmRH8F29USCzyqimiDey0nhPctfrtvg6ClE=";
  };

  src = runCommand "${pname}-${version}.AppImage" { nativeBuildInputs = [ unzip ]; } ''
    unzip -p ${artifact} JellyfinDesktop-${version}-x86_64.AppImage > $out
    chmod +x $out
  '';

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/org.jellyfin.JellyfinDesktop.desktop \
      $out/share/applications/org.jellyfin.JellyfinDesktop.desktop
    install -Dm444 ${appimageContents}/org.jellyfin.JellyfinDesktop.svg \
      $out/share/icons/hicolor/scalable/apps/org.jellyfin.JellyfinDesktop.svg
    install -Dm444 ${appimageContents}/usr/share/metainfo/org.jellyfin.JellyfinDesktop.metainfo.xml \
      $out/share/metainfo/org.jellyfin.JellyfinDesktop.metainfo.xml
  '';

  meta = {
    description = "Jellyfin desktop client built on CEF and mpv";
    homepage = "https://github.com/jellyfin/jellyfin-desktop";
    license = lib.licenses.gpl2Only;
    mainProgram = "jellyfin-desktop";
    platforms = [ "x86_64-linux" ];
  };
}
