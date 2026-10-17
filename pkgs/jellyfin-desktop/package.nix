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
  version = "3.0.0-dev+28f2cf1";
  rev = "28f2cf16a1f1b819884dd6a72919ca55bdf9bd73";

  cefBinary = cef-binary.override {
    version = "151.3.16";
    gitRevision = "be1e15d";
    chromiumVersion = "151.0.7922.109";
    srcHashes = {
      x86_64-linux = "sha256-6usxPmA53kZIVYk9KHxNXrTscSaXjqg8YWS/SiPcAXo=";
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
    owner = "andrewrabert";
    repo = "jellium-desktop";
    inherit rev;
    hash = "sha256-fMk5bZRMi6FgTGigu3/fYX9sj1HmKW5mp+Ipc+BO+tQ=";
  };

  cargoRoot = "src";
  cargoLock = {
    lockFile = "${finalAttrs.src}/src/Cargo.lock";
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
    patchelf --shrink-rpath $out/libexec/jellyfin-desktop/jellium-desktop

    install -dm755 $out/bin
    makeWrapper $out/libexec/jellyfin-desktop/jellium-desktop $out/bin/jellium-desktop \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    install -Dm644 resources/linux/net.nullsum.JelliumDesktop.desktop \
      $out/share/applications/net.nullsum.JelliumDesktop.desktop
    install -Dm644 resources/linux/net.nullsum.JelliumDesktop.metainfo.xml \
      $out/share/metainfo/net.nullsum.JelliumDesktop.metainfo.xml
    install -Dm644 resources/linux/net.nullsum.JelliumDesktop.svg \
      $out/share/icons/hicolor/scalable/apps/net.nullsum.JelliumDesktop.svg
    install -Dm644 LICENSE $out/share/licenses/jellyfin-desktop/LICENSE

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit cef cefBinary mpvPrefix;
  };

  meta = {
    description = "Unofficial Jellyfin desktop client built on CEF and mpv";
    homepage = "https://github.com/andrewrabert/jellium-desktop";
    license = lib.licenses.gpl2Plus;
    mainProgram = "jellium-desktop";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
