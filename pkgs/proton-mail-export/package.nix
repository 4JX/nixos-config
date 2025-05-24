# Adapted from https://github.com/42LoCo42/obscura/tree/f85930b88eec8b5d0fa3d8490f2dc2d2810d04d6/packages/proton-mail-export
{
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  clang-tools,
  cmake,
  go,
  ninja,
  catch2_3,
  cxxopts,
  fmt,
}:

let
  pname = "proton-mail-export";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AbIS7iB5y1+vOfvAgw8mRNRTvuzdE2ML6Izod+BMCUE=";
  };

  inherit
    (buildGoModule {
      inherit pname version;
      src = "${src}/go-lib";
      vendorHash = "sha256-0JsJO5E9Y7DpuZfWHFpqZKO8PPsCokl+YS5zs+zLt30=";
    })
    goModules
    ;
in
stdenv.mkDerivation {
  inherit pname version src;

  patches = [
    ./0001-cmake-disable-vcpkg.patch
    ./0002-dont-write-logs-in-exe-directory.patch
  ];

  nativeBuildInputs = [
    clang-tools # clang-tidy
    cmake
    go
    ninja
  ];

  buildInputs = [
    catch2_3
    cxxopts
    fmt
  ];

  preConfigure = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH="$TMPDIR/go"
    export GOPROXY=off
    export GOSUMDB=off

    cp -r --reflink=auto "${goModules}" go-lib/vendor
  '';

  postInstall = ''
    cd $out

    # meta only includes version.json, which we don't need
    rm -rf $out/meta

    # for some reason, the library is installed into bin
    mkdir lib
    mv {bin,lib}/${pname}.so
  '';

  meta = {
    description = "Proton Mail Export allows you to export your emails as eml files";
    homepage = "https://github.com/ProtonMail/proton-mail-export";
    mainProgram = "${pname}-cli";
  };
}
