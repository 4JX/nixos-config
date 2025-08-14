# Mix of
# https://github.com/Steven0351/nix-darwin-dotfiles/blob/d0ef9ecb05551ac74a7a70b58b321358473c3a91/derivations/otf-apple.nix#L12
# https://github.com/wkj9893/dotfiles/blob/b20353b7d399dee89a4ae7cf6e5d77ee356ea496/overlays/apple-font.nix#L17

{
  stdenvNoCC,
  fetchurl,
  p7zip,
}:

stdenvNoCC.mkDerivation {
  pname = "otf-apple";
  version = "1.0";

  src = [
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      sha256 = "sha256-090HwtgILtK/KGoOzcwz1iAtoiShKAVjiNhUDQtO+gQ=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      sha256 = "sha256-bUoLeOOqzQb5E/ZCzq0cfbSvNO1IhW1xcaLgtV2aeUU=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      sha256 = "sha256-z70mts7oFaMTt4q7p6M7PzSw4auOEaiaJPItYqUpN0A=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      sha256 = "sha256-HC7ttFJswPMm+Lfql49aQzdWR2osjFYHJTdgjtuI+PQ=";
    })
  ];

  buildInputs = [ p7zip ];
  sourceRoot = "./Library/Fonts";
  preUnpack = "mkdir fonts";
  unpackCmd = ''
    7z x $curSrc
    find . -name "*.pkg" -exec 7z x {} \;
    find . -name "Payload~" -exec 7z x {} \;
  '';
  installPhase = ''
    find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/truetype {} \;
    find . -name '*.otf' -exec install -m444 -Dt $out/share/fonts/opentype {} \;
  '';
}
