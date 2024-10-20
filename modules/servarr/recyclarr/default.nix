{ config, lib, pkgs, myLib, ... }:

# TODO: More granular profile management with https://recyclarr.dev/wiki/yaml/config-reference/ and https://github.com/MasterMidi/nixos-config/blob/d26bd35bfb328bab2c5dc2733bc1c7de5e2c4faa/hosts/servers/david/recyclarr/
# Written via pkgs.writers.writeYAML "recyclarr.yaml" { settings = "foo"; } since it gives more flexibility
# Or at least with includes https://recyclarr.dev/wiki/yaml/config-reference/include/
let
  # https://recyclarr.dev/wiki/guide-configs/
  # https://github.com/recyclarr/config-templates/blob/master/sonarr/templates/anime-sonarr-v4.yml
  recyclarrYaml = ./recyclarr.yml;

  servarrCfg = config.ncfg.servarr;
  cfg = servarrCfg.recyclarr;

  sonarrEnabled = servarrCfg.sonarr.enable;
  radarrEnabled = servarrCfg.radarr.enable;

  inherit (lib) mkPackageOption mkOption;
in
{
  options.ncfg.servarr.recyclarr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = sonarrEnabled || radarrEnabled;
      description = "Whether to enable the Recyclarr service.";
    };
    package = mkPackageOption pkgs "recyclarr" { };
    config.version = mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkIf (sonarrEnabled && cfg.enable) {
    assertions = [ (myLib.mkVersionAssertion pkgs.recyclarr cfg.config.version) ];

    environment.systemPackages = [ cfg.package ];


    systemd.services.recyclarr =
      let
        backend = config.virtualisation.oci-containers.backend;

        enabledServices = lib.pipe config.systemd.services
          [
            builtins.attrNames
            (builtins.filter (v: (builtins.match "${backend}-(sonarr|radarr)(-[^-]+)*" v) != null))
            (builtins.map (v: "${v}.service"))
          ];
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
