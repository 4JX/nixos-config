{ lib, pkgs, stdenvNoCC, ... }:

stdenvNoCC.mkDerivation {
  pname = "mpv-jellyfin";
  version = "1.1";

  src = pkgs.fetchFromGitHub {
    owner = "EmperorPenguin18";
    repo = "mpv-jellyfin";
    rev = "0caf809";
    sha256 = "sha256-e3LjuP+rgxpgpeVlcbgFm48XtOivuWV2puMJM5F6ezg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src/scripts/jellyfin.lua $out/share/mpv/scripts/jellyfin.lua

    runHook postInstall
  '';

  passthru.scriptName = "jellyfin.lua";

  meta = with lib; {
    description = "mpv plugin that turns it into a Jellyfin client";
    homepage = "https://github.com/EmperorPenguin18/mpv-jellyfin";
    license = licenses.unlicense;
    # mantainers = ;
  };
}
