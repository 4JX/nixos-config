# https://github.com/NixOS/nixpkgs/blob/0742d7dae9403fbda29f4544ca4ad411e6494d3a/pkgs/by-name/pr/proton-ge-bin/package.nix
{
  lib,
  stdenvNoCC,
  fetchzip,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "GE-Proton-621",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-ge-bin";
  version = "6.21-GE-2";

  # https://github.com/GloriousEggroll/proton-ge-custom/releases/tag/6.21-GE-2
  # https://github.com/GloriousEggroll/proton-ge-custom/releases/download/6.21-GE-2/Proton-6.21-GE-2.tar.gz
  src = fetchzip {
    url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/Proton-${finalAttrs.version}.tar.gz";
    hash = "sha256-4fjZMkBtb49fNmRmooXN6XsY4SJYEhUeYFO2UFOIaUg=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "Proton-${finalAttrs.version}" "${steamDisplayName}"
  '';

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      Gliczy
      NotAShelf
      Scrumplex
      shawn8901
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
