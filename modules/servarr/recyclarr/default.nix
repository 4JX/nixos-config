{ config, lib, pkgs, myLib, ... }:

# TODO: More granular profile management with https://recyclarr.dev/wiki/yaml/config-reference/ and https://github.com/MasterMidi/nixos-config/blob/d26bd35bfb328bab2c5dc2733bc1c7de5e2c4faa/hosts/servers/david/recyclarr/
# Written via pkgs.writers.writeYAML "recyclarr.yaml" { settings = "foo"; } since it gives more flexibility
# Or at least with includes https://recyclarr.dev/wiki/yaml/config-reference/include/
let
  # https://recyclarr.dev/wiki/guide-configs/#anime-sonarr-v4
  # https://github.com/recyclarr/config-templates/blob/master/sonarr/templates/anime-sonarr-v4.yml
  recyclarrYaml = ./recyclarr.yml;
  servarrEnable = config.ncfg.servarr.enable;
  cfg = config.ncfg.servarr.recyclarr;
  inherit (lib) mkEnableOption mkPackageOption mkOption;
in

{
  options.ncfg.servarr.recyclarr = {
    enable = mkEnableOption "the Recyclarr service";
    package = mkPackageOption pkgs "recyclarr" { };
    configVersion = mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf (servarrEnable && cfg.enable) {
    assertions = [ (myLib.mkVersionAssertion pkgs.recyclarr cfg.configVersion) ];

    environment.systemPackages = [ cfg.package ];


    systemd.services.recyclarr =
      let
        sonarrEnabled = config.services.sonarr.enable;
        radarrEnabled = config.services.radarr.enable;
        enabledServices =
          lib.optionals sonarrEnabled [ "sonarr.service" ] ++
          lib.optionals radarrEnabled [ "radarr.service" ];
      in
      {
        description = "Recyclarr Sync Service";
        after = enabledServices;
        requires = enabledServices;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${cfg.package}/bin/recyclarr sync --config ${recyclarrYaml}";
        };
      };

    systemd.timers.recyclarr = {
      description = "Recyclarr Sync Timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = [ "daily" ];
        Persistent = true;
      };
    };
  };
}
