{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "6.21-GE-2";

  # https://github.com/GloriousEggroll/proton-ge-custom/releases/download/6.21-GE-2/Proton-6.21-GE-2.tar.gz
  src = fetchurl {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/Proton-${version}.tar.gz";
    sha256 = "sha256-mN6hACGuGyo+zkkANO9YgMtPd4tHPvGzOthCo52Mgx8=";
  };

  buildCommand = ''
    mkdir -p $out
    tar -C $out --strip=1 -x -f $src
  '';
}
