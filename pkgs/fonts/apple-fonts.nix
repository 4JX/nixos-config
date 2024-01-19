# Mix of
# https://github.com/Steven0351/nix-darwin-dotfiles/blob/d0ef9ecb05551ac74a7a70b58b321358473c3a91/derivations/otf-apple.nix#L12
# https://github.com/wkj9893/dotfiles/blob/b20353b7d399dee89a4ae7cf6e5d77ee356ea496/overlays/apple-font.nix#L17

{ stdenvNoCC
, fetchurl
, p7zip
,
}:

stdenvNoCC.mkDerivation {
  pname = "otf-apple";
  version = "1.0";

  src = [
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
      sha256 = "sha256-Mu0pmx3OWiKBmMEYLNg+u2MxFERK07BQGe3WAhEec5Q=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
      sha256 = "sha256-tZHV6g427zqYzrNf3wCwiCh5Vjo8PAai9uEvayYPsjM=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
      sha256 = "sha256-Mkf+GK4iuUhZdUdzMW0VUOmXcXcISejhMeZVm0uaRwY=";
    })
    (fetchurl {
      url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
      sha256 = "sha256-tn1QLCSjgo5q4PwE/we80pJavr3nHVgFWrZ8cp29qBk=";
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
