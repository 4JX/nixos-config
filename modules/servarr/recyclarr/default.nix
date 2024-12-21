{ config, lib, ... }:

# TODO: More granular profile management with https://recyclarr.dev/wiki/yaml/config-reference/ and https://github.com/MasterMidi/nixos-config/blob/d26bd35bfb328bab2c5dc2733bc1c7de5e2c4faa/hosts/servers/david/recyclarr/
# Written via pkgs.writers.writeYAML "recyclarr.yaml" { settings = "foo"; } since it gives more flexibility
# Or at least with includes https://recyclarr.dev/wiki/yaml/config-reference/include/
let
  # https://recyclarr.dev/wiki/guide-configs/
  recyclarrYaml = ./recyclarr.yml;

  servarrCfg = config.ncfg.servarr;
  cfg = servarrCfg.recyclarr;

  sonarrEnabled = servarrCfg.sonarr.tv-hd.enable || servarrCfg.sonarr.anime.enable;
  radarrEnabled = servarrCfg.radarr.movies-hd.enable || servarrCfg.radarr.movies-uhd.enable;

  username = config.users.users.nobody.name;
  group = config.users.users.nobody.group;
in
{
  options.ncfg.servarr.recyclarr = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = sonarrEnabled || radarrEnabled;
      description = "Whether to enable the Recyclarr service.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.recyclarr = {
      sopsFile = servarrCfg.secretsFolder + "/recyclarr.yaml";
      # Serve the whole YAML file
      key = "";
      # The container will also run as the same user/group
      owner = username;
      group = group;
    };

    # Extracted from docker-compose.nix
    virtualisation.oci-containers.containers."recyclarr" = {
      image = "ghcr.io/recyclarr/recyclarr";
      environment = {
        "TZ" = config.time.timeZone;
      };
      volumes = [
        "${recyclarrYaml}:/config/recyclarr.yml:rw"
        "${config.sops.secrets.recyclarr.path}:/config/secrets.yml:rw"
        "/containers/config/recyclarr:/config:rw"
      ];
      dependsOn = [
        "radarr-movies-hd"
        "sonarr-tv-hd"
        "sonarr-anime"
      ];
      user = "${username}:${group}";
      log-driver = "journald";
      extraOptions = [
        "--network-alias=recyclarr"
        "--network=arr"
      ];
    };
    systemd.services."docker-recyclarr" = {
      serviceConfig = {
        Restart = lib.mkOverride 90 "no";
      };
      after = [
        "docker-network-arr.service"
      ];
      requires = [
        "docker-network-arr.service"
      ];
      partOf = [
        "docker-compose-servarr-root.target"
      ];
      wantedBy = [
        "docker-compose-servarr-root.target"
      ];
    };
  };
}
