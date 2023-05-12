{ pkgs }:

let
  nixpkgsPR = { rev, path, sha256 }: pkgs.callPackage
    (pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/${rev}/${path}";
      inherit sha256;
    })
    { };
in
{
  # https://github.com/NixOS/nixpkgs/pull/231474
  mpvScripts.thumbfast = nixpkgsPR {
    rev = "86eb0d9a05db24b40585dc9f7c0fe7d5f2f09877";
    path = "pkgs/applications/video/mpv/scripts/thumbfast.nix";
    sha256 = "sha256-uBBEsOsSlTnNat2FdHHMskA++riIqgicKAoDQJsyNK8=";
  };

  # auto-cpufreq 1.9.6
  # https://github.com/NixOS/nixpkgs/pull/226458
  auto-cpufreq = nixpkgsPR {
    rev = "01de1c4569947df5f3bd36b2e8042023666bde66";
    path = "pkgs/tools/system/auto-cpufreq/default.nix";
    sha256 = "sha256-rol2CSTGRV6PKq98bj8Tpcw7EUErEHSMlziOxneiFPQ=";
  };
}
