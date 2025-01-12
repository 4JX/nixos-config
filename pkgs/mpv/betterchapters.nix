{ lib, stdenvNoCC, fetchurl, ... }:

let
  filename = "betterchapters.lua";
  rev = "1d1daf22f0ec5f0219e4e72216e772828f5c8e4c";
  shortRev = builtins.substring 0 8 rev;
in
stdenvNoCC.mkDerivation rec {
  pname = "mpv-betterChapters";
  version = shortRev;

  src = fetchurl {
    url = "https://gist.githubusercontent.com/Hakkin/4f978a5c87c31f7fe3ae/raw/${rev}/${filename}";
    sha256 = "sha256-bPH9sm/aO/FnWYY8K+2DFjFahaOCrSj5Es2bqfBk9ow=";
  };

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${src} $out/share/mpv/scripts/${filename}

    runHook postInstall
  '';

  passthru.scriptName = filename;

  meta = with lib; {
    description = "Loads the next or previous playlist entry if there are no more chapters in the seek direction.";
    homepage = "https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae";
    license = licenses.unfree;
    # maintainers = ;
  };
}
