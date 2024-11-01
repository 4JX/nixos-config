{ pkgs, ... }:

{
  mpvScripts = {
    betterChapters = pkgs.callPackage ./betterchapters.nix { };
    evafast = pkgs.callPackage ./evafast.nix { };
    pauseWhenMinimize = pkgs.callPackage ./pauseWhenMinimize.nix { };
    mpv-jellyfin = pkgs.callPackage ./mpv-jellyfin.nix { };
  };

  shaders = {
    # https://gist.github.com/igv
    SSimSuperRes = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b/raw/15d93440d0a24fc4b8770070be6a9fa2af6f200b/SSimSuperRes.glsl";
      sha256 = "sha256-qLJxFYQMYARSUEEbN14BiAACFyWK13butRckyXgVRg8=";
    };

    SSimDownscaler = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/6998ff663a135376dbaeb6f038e944d806a9b9d9/SSimDownscaler.glsl";
      sha256 = "sha256-FF3rw4DzwgWLHSkziQXSvIBgAxVtZ0skdFJ03S1QmQY=";
    };

    KrigBilateral = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/7c151e0af2281ae6657809be1f3c5efe0e325c38/KrigBilateral.glsl";
      sha256 = "sha256-uIbPX59nIHeHC9wa1Mv1nQartUusOgXaEHQyA95BST8=";
    };

    fsrcnnx = pkgs.callPackage ./fsrcnnx.nix { };
  };
}
