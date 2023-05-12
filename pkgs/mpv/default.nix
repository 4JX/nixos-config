{ pkgs, lib, ... }:

let
  singleFileScript = inputs@{ pname, rev, filename, url, sha256, meta }: pkgs.callPackage
    (
      import ./single-file.nix inputs
    )
    { };
in
{
  mpvScripts = {
    betterChapters = singleFileScript rec {
      pname = "mpv-betterChapters";
      rev = "1d1daf22f0ec5f0219e4e72216e772828f5c8e4c";
      filename = "betterchapters.lua";
      url = "https://gist.githubusercontent.com/Hakkin/4f978a5c87c31f7fe3ae/raw/${rev}/${filename}";
      sha256 = "sha256-bPH9sm/aO/FnWYY8K+2DFjFahaOCrSj5Es2bqfBk9ow=";
      meta = with lib; {
        description = "Loads the next or previous playlist entry if there are no more chapters in the seek direction.";
        homepage = "https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae";
        license = licenses.unfree;
        # mantainers = ;
      };
    };

    # Pay attention to https://github.com/po5/evafast/pull/8
    evafast = singleFileScript rec {
      pname = "mpv-evafast";
      rev = "f9ee7e41dedf0f65186900e0ccdd6ca6a8ced7ed";
      filename = "evafast.lua";
      url = "https://raw.githubusercontent.com/po5/evafast/${rev}/${filename}";
      sha256 = "sha256-UkqWhHws0V7rV5f2w7g3d0jHvEP70zhbomE8AQIiwh0=";
      meta = with lib; {
        description = "mpv script for hybrid fastforward and seeking";
        homepage = "https://github.com/po5/evafast";
        license = licenses.unfree;
        # mantainers = ;
      };
    };

    pauseWhenMinimize = pkgs.callPackage ./pauseWhenMinimize.nix { };
  };

  anime4k = pkgs.callPackage ./an4k.nix { };
}
