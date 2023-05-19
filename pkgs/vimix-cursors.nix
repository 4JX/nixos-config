# https://github.com/nix-community/nur-combined/blob/8262ec00e5f1f10b2fb2e4bd3ea5444e0acf135b/repos/ambroisie/pkgs/vimix-cursors/default.nix#L32
{ lib, python3, fetchFromGitHub, inkscape, stdenvNoCC, xcursorgen }:
let
  py = python3.withPackages (ps: with ps; [ cairosvg ]);
in
stdenvNoCC.mkDerivation rec {
  pname = "vimix-cursors";
  version = "unstable-2020-04-28";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = pname;
    rev = "9bc292f40904e0a33780eda5c5d92eb9a1154e9c";
    hash = "sha256-zW7nJjmB3e+tjEwgiCrdEe5yzJuGBNdefDdyWvgYIUU=";
  };

  nativeBuildInputs = [
    inkscape
    py
    xcursorgen
  ];

  postPatch = ''
    patchShebangs .
  '';

  buildPhase = ''
    HOME="$NIX_BUILD_ROOT" ./build.sh
  '';

  installPhase = ''
    install -dm 755 $out/share/icons
    for color in "" "-white"; do
      cp -pr dist''${color}/  "$out/share/icons/Vimix''${color}-cursors"
    done
  '';

  meta = with lib; {
    description = "An X cursor theme inspired by Materia design";
    homepage = "https://github.com/vinceliuice/Vimix-cursors";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ambroisie ];
  };
}
