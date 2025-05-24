{
  lib,
  stdenvNoCC,
  fetchurl,
  ...
}:

let
  filename = "evafast.lua";
  rev = "f9ee7e41dedf0f65186900e0ccdd6ca6a8ced7ed";
  shortRev = builtins.substring 0 8 rev;
in
stdenvNoCC.mkDerivation rec {
  pname = "mpv-evafast";
  version = shortRev;

  # Pay attention to https://github.com/po5/evafast/pull/8
  src = fetchurl {
    url = "https://raw.githubusercontent.com/po5/evafast/${rev}/${filename}";
    sha256 = "sha256-UkqWhHws0V7rV5f2w7g3d0jHvEP70zhbomE8AQIiwh0=";
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
    description = "mpv script for hybrid fastforward and seeking";
    homepage = "https://github.com/po5/evafast";
    license = licenses.unfree;
    # maintainers = ;
  };
}
