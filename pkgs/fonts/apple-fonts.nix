# Mix of
# https://github.com/Steven0351/nix-darwin-dotfiles/blob/d0ef9ecb05551ac74a7a70b58b321358473c3a91/derivations/otf-apple.nix#L12
# https://github.com/wkj9893/dotfiles/blob/b20353b7d399dee89a4ae7cf6e5d77ee356ea496/overlays/apple-font.nix#L17

{ stdenvNoCC
, fetchurl
, p7zip
,
}:

{
  otf-apple = stdenvNoCC.mkDerivation {
    pname = "otf-apple";
    version = "1.0";

    src = [
      (fetchurl {
        url = "https://devimages-cdn.apple.com/design/resources/download/SF-Pro.dmg";
        sha256 = "sha256-WG0nLn/Giiv0DT8zUwTiWuv/I23RqMSxJsGUbrQzCqc=";
      })
      (fetchurl {
        url = "https://devimages-cdn.apple.com/design/resources/download/SF-Mono.dmg";
        sha256 = "sha256-pqkYgJZttKKHqTYobBUjud0fW79dS5tdzYJ23we9TW4=";
      })
      (fetchurl {
        url = "https://devimages-cdn.apple.com/design/resources/download/SF-Compact.dmg";
        sha256 = "sha256-uMGSFvqAfTdUWhNE6D6RyLKCrt4VXrUNZppvTHM7Igg=";
      })
      (fetchurl {
        url = "https://devimages-cdn.apple.com/design/resources/download/NY.dmg";
        sha256 = "sha256-XOiWc4c7Yah+mM7axk8g1gY12vXamQF78Keqd3/0/cE=";
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
  };
}
