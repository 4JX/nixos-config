{ stdenv, pkgs }:

stdenv.mkDerivation {
  name = "Custom fonts";

  src = ./zips;

  nativeBuildInputs = with pkgs; [ unzip ];

  # Font types
  # *.ttf -> TrueType Font
  # *.otf -> OpenType Font
  # *.woff, *.woff2 (?)
  installPhase = ''
    find . -name "*.zip" -type f -exec unzip -j {} "*.ttf" "*.otf" "*.woff" "*.woff2" \;

    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/fonts/opentype
    mkdir -p $out/share/fonts/woff
    mkdir -p $out/share/fonts/woff2
    cp *.ttf $out/share/fonts/truetype
    cp *.otf $out/share/fonts/opentype
    cp *.woff $out/share/fonts/woff
    cp *.woff2 $out/share/fonts/woff2
  '';
}
