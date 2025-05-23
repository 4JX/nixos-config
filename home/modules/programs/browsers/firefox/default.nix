{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

# https://github.com/schizofox/schizofox is nice but is pretty opinionated and uses its own preferences rather than arkenfox
# though it can definitely be used as a base
let
  cfg = config.local.programs.browsers.firefox;

  firefoxVersion = "${lib.versions.major config.programs.firefox.package.version}.0";

  # Technically also in arkenfox.supportedVersions
  defaultArkenfoxVersion =
    if inputs.arkenfox-nixos.lib.arkenfox.extracted ? ${firefoxVersion} then
      firefoxVersion
    else
      "master";
in
{
  # https://github.com/dwarfmaster/arkenfox-nixos
  imports = [ inputs.arkenfox-nixos.hmModules.arkenfox ];

  options.local.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Firefox";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      arkenfox = {
        enable = true;
        version = defaultArkenfoxVersion;
      };

      profiles = import ./profiles.nix { inherit pkgs lib; };
    };
  };
}
