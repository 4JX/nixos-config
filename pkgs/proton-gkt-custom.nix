{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "wine-tkg-git";
  version = "fd53a4b";

  src = fetchFromGitHub {
    owner = "Frogging-Family";
    repo = "wine-tkg-git";
    rev = version;
    sha256 = "sha256-QeE/bMZ8fUtCk66V+1xXHBfxR+GKbsVIsju/oJ1r9ps=";
  };

  buildCommand = ''
    ls
    cd $src
    cd proton-tkg
    patchShebangs ./proton-tkg.sh
  '';
}
