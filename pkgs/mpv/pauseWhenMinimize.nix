{ lib, pkgs, stdenvNoCC, ... }:

stdenvNoCC.mkDerivation {
  pname = "mpv-pause-when-minimize";
  version = pkgs.mpv-unwrapped.version;

  src = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/pause-when-minimize.lua";

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/mpv/scripts/pause-when-minimize.lua

    runHook postInstall
  '';

  passthru.scriptName = "pause-when-minimize.lua";

  meta = with lib; {
    description = "Pauses the player video when minimizing, and unpauses it when brought up again.";
    homepage = "https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae";
    license = licenses.gpl2Plus;
    # mantainers = ;
  };
}
