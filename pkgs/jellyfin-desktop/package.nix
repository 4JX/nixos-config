{
  cef-binary,
  cmake,
  ffmpeg-headless,
  fetchFromGitHub,
  lib,
  libGL,
  libglvnd,
  libxcb,
  libxcb-cursor,
  libxkbcommon,
  makeWrapper,
  mpv-unwrapped,
  ninja,
  pkg-config,
  rustPlatform,
  stdenv,
  symlinkJoin,
  systemdLibs,
  wayland,
}:

let
  pname = "jellyfin-desktop";
  version = "3.0.0-dev+225af09";
  rev = "225af09b41e8aa98a13f2f03e7e50f471c15fd16";

  cefBinary = cef-binary.override {
    version = "149.0.6";
    gitRevision = "0d0eeb6";
    chromiumVersion = "149.0.7827.201";
    srcHashes = {
      x86_64-linux = "sha256-+Q3sTFxCp7vU8r2Ap6d+Csaqz8Zie7Q1ctgD538m37w=";
    };
  };

  cef = stdenv.mkDerivation {
    pname = "cef-for-jellyfin-desktop";
    inherit (cefBinary) version;
    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ${cefBinary}/Release/. $out/
      cp -r ${cefBinary}/Resources/. $out/
      cp -r ${cefBinary}/include $out/include

      runHook postInstall
    '';
  };

  mpvPrefix = symlinkJoin {
    name = "mpv-external-prefix";
    paths = [
      (lib.getDev mpv-unwrapped)
      (lib.getLib mpv-unwrapped)
    ];
  };

  runtimeLibs = [
    libGL
    libglvnd
    libxcb
    libxcb-cursor
    libxkbcommon
    systemdLibs
    wayland
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-desktop";
    inherit rev;
    hash = "sha256-Dvqz+3Miky9SQNB71o+SNal/zSi1x8q56rCuM3R8HFY=";
  };

  cargoRoot = "src";
  cargoHash = "sha256-dcgkX/j0c4nZ/75sYHNlIMuYhPf37LfBBe6jsD5i2QM=";
  cargoLock = {
    lockFile = "${finalAttrs.src}/src/Cargo.lock";
    outputHashes = {
      "wl-proxy-0.1.2" = "sha256-8NMNPhBSW2gLXc9bwyg2kmHb12XIaV6b4PjM62xLldQ=";
    };
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    makeWrapper
    ninja
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = runtimeLibs ++ [
    ffmpeg-headless
  ];

  env = {
    JFN_GIT_HASH = rev;
    JFN_GIT_DIRTY = "0";
  };

  buildPhase = ''
    runHook preBuild

    cargo run --quiet --release \
      --manifest-path src/xtask/Cargo.toml -- \
      build \
        --cef-path ${cef} \
        --external-mpv ${mpvPrefix} \
        --out build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    rm -rf build/cargo-target

    install -dm755 $out/libexec/jellyfin-desktop
    cp -r build/. $out/libexec/jellyfin-desktop/
    patchelf --shrink-rpath $out/libexec/jellyfin-desktop/jellyfin-desktop

    install -dm755 $out/bin
    makeWrapper $out/libexec/jellyfin-desktop/jellyfin-desktop $out/bin/jellyfin-desktop \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    install -Dm644 resources/linux/org.jellyfin.JellyfinDesktop.desktop \
      $out/share/applications/org.jellyfin.JellyfinDesktop.desktop
    install -Dm644 resources/linux/org.jellyfin.JellyfinDesktop.metainfo.xml \
      $out/share/metainfo/org.jellyfin.JellyfinDesktop.metainfo.xml
    install -Dm644 resources/linux/org.jellyfin.JellyfinDesktop.svg \
      $out/share/icons/hicolor/scalable/apps/org.jellyfin.JellyfinDesktop.svg
    install -Dm644 LICENSE $out/share/licenses/jellyfin-desktop/LICENSE

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit cef cefBinary mpvPrefix;
  };

  meta = {
    description = "Jellyfin desktop client built on CEF and mpv";
    homepage = "https://github.com/jellyfin/jellyfin-desktop";
    license = lib.licenses.gpl2Only;
    mainProgram = "jellyfin-desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
