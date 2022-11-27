{ pkgs, lib, ... }:
let
  version = "107.0";
  arkenfox_user = builtins.readFile (pkgs.fetchzip
    {
      url = "https://github.com/arkenfox/user.js/archive/refs/tags/${version}.tar.gz";
      sha256 = "4d92a802bcc02ee08d58d06adee9f4f75791dee44b022e7dcff019eb85e0dc14";
    } + /user.js);

  overrides = { "keyword.enabled" = true; };

  final = ''
    ${arkenfox_user}


    // Manual overrides
    ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
    user_pref("${name}", ${builtins.toJSON value});
    '') overrides)}
  '';

in
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      extraConfig = final;
    };
  };
}
