{
  stdenvNoCC,
  ...
}:

let
  filename = "betterChapters.lua";
in
stdenvNoCC.mkDerivation rec {
  pname = "mpv-betterChapters";
  version = "1.0.0";

  # https://github.com/mpv-player/mpv/issues/4738#issuecomment-321298846
  # Updated from https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae
  src = ./betterChapters.lua;

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${src} $out/share/mpv/scripts/${filename}

    runHook postInstall
  '';

  passthru.scriptName = filename;

  meta = {
    description = "Loads the next or previous playlist entry if there are no more chapters in the seek direction.";
    homepage = "https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae";
    # license = licenses.unlicense;
    # maintainers = ;
  };
}
