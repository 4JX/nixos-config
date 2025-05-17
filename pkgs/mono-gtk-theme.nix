{
  lib,
  stdenvNoCC,
  fetchzip,
  gnome-themes-extra,
  gtk-engine-murrine,
}:
let
  folderName = "MonoThemeDark";
in
stdenvNoCC.mkDerivation rec {
  pname = "mono-gtk-theme";
  version = "1.3";

  src = fetchzip {
    url = "https://github.com/witalihirsch/Mono-gtk-theme/releases/download/${version}/${folderName}.tar.xz";
    sha256 = "sha256-wQvRdJr6LWltnk8CMchu2y5zPXM5k7m0EOv4w4R8l9U=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  buildInputs = [
    gnome-themes-extra
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    folder=$out/share/themes/${folderName}
    mkdir -p $folder
    cp -a * $folder
    runHook postInstall
  '';

  meta = with lib; {
    description = "Mono Theme for Gnome";
    homepage = "https://github.com/witalihirsch/Mono-gtk-theme";
    license = licenses.gpl3Only;
    platforms = platforms.unix;
    # maintainers = [ maintainers.math-42 ];
  };
}
