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
  # auto-cpufreq 1.9.6
  # https://github.com/NixOS/nixpkgs/pull/226458
  # auto-cpufreq = nixpkgsPR {
  #   rev = "01de1c4569947df5f3bd36b2e8042023666bde66";
  #   path = "pkgs/tools/system/auto-cpufreq/default.nix";
  #   sha256 = "sha256-rol2CSTGRV6PKq98bj8Tpcw7EUErEHSMlziOxneiFPQ=";
  # };
}
