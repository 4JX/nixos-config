{ lib, config, pkgs, inputs, ... }:

# TODO: Implement https://github.com/dwarfmaster/arkenfox-nixos for the best arkenfox setup, should also make overriding its 
# settings easier than the currently implemented cfg.arkenfox.overrides, especially for "search on enter" and "letterboxing"

# https://github.com/schizofox/schizofox is nice but is pretty opinionated and uses its own preferences rather than arkenfox
# though it can definitely be used as a base
let
  cfg = config.ncfg.programs.browsers.firefox;
  # Note that we lose on version pinning by using an input, but since this is intended to be used with nixos-unstable
  # the repo should always stay "in sync" with the version of firefox
  # arkenfox_user = builtins.readFile (pkgs.fetchzip
  # {
  #   url = "https://github.com/arkenfox/user.js/archive/refs/tags/${cfg.arkenfox.firefoxVersion}.tar.gz";
  #   inherit (cfg.arkenfox) sha256;
  # } + /user.js);
  arkenfox_user = builtins.readFile (inputs.arkenfox + /user.js);

  # layout.css.visited_links_enabled = true; Enables history scraping via various a:visited selector thingmabobs, is it really worth it?
  final = ''
    ${arkenfox_user}


    // Manual overrides
    ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
    user_pref("${name}", ${builtins.toJSON value});
    '') cfg.arkenfox.overrides)}
  '';

in
{
  options.ncfg.programs.browsers.firefox = {
    enable = lib.mkEnableOption "Firefox";
    arkenfox = {
      # firefoxVersion = lib.mkOption {
      #   type = lib.types.strMatching "[0-9]{1,3}\.[0-9]";
      #   default = builtins.elemAt (builtins.match "([0-9]+\.[0-9]+)\.*" pkgs.firefox.version) 0;
      # };
      # sha256 = lib.mkOption {
      #   type = lib.types.str;
      # };
      overrides = lib.mkOption {
        default = { };
        type = lib.types.attrs;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          extraConfig = final;
          search = {
            # Data for these is extracted from ~/.mozilla/firefox/default/search.json.mozlz4 with "nix-shell -p dejsonlz4"
            engines = {
              "google".metaData.hidden = true;
              "qwant".metaData.hidden = true;
              "bing".metaData.hidden = true;
              "ecosia".metaData.hidden = true;

              "SearXNG" = {
                loadPath = "[https]search.sapti.me/sams-searxng.xml";
                description = "SearXNG is a metasearch engine that respects your privacy.";
                urls = [{
                  rels = [ "results" ];
                  template = "https://search.sapti.me/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }
                  {
                    rels = [ "suggestions" ];
                    template = "https://search.sapti.me/autocompleter";
                    params = [
                      { name = "q"; value = "{searchTerms}"; }
                    ];
                    "type" = "application/x-suggestions+json";
                  }];
                icon = ./engine-logos/searx.svg;
                definedAliases = [ "@s" ];
              };

              "LibRedirect" = {
                loadPath = "[other]addEngineWithDetails:7esoorv3@alefvanoon.anonaddy.me";
                description = "A web extension that redirects popular sites to alternative privacy-friendly frontends and backends";
                urls = [{
                  template = "https://search.libredirect.invalid/";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                icon = ./engine-logos/libredirect.png;
                iconMapObj = {
                  "16" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-16.png";
                  "32" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-32.png";
                  "48" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-48.png";
                  "64" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-64.png";
                  "96" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-96.png";
                  "128" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-128.png";
                };
                definedAliases = [ "@lb" ];
                _extensionID = "7esoorv3@alefvanoon.anonaddy.me";
              };

              "wikipedia".metaData.alias = "@w";

              "ddg".metaData.alias = "@ddg";

              "GitHub" = {
                urls = [{
                  template = "https://github.com/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                icon = ./engine-logos/github.svg;
                definedAliases = [ "@gh" ];
              };

              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    { name = "channel"; value = "unstable"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };

              "NixOS Wiki" = {
                urls = [{
                  template = "https://nixos.wiki/index.php";
                  params = [{ name = "search"; value = "{searchTerms}"; }];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@nw" ];
              };

              "Nixpkgs Issues" = {
                urls = [{
                  template = "https://github.com/NixOS/nixpkgs/issues";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [
                  "@ni"
                ];
              };

              # The urls are not changed since LibRedirect will manage the instances part
              "LibReddit" = {
                urls = [{
                  template = "https://www.reddit.com/search";
                  params = [
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                icon = ./engine-logos/libreddit.svg;
                definedAliases = [ "@r" ];
              };

              "Invidious" = {
                urls = [{
                  template = "https://www.youtube.com/results";
                  params = [{ name = "search_query"; value = "{searchTerms}"; }];
                }];
                icon = ./engine-logos/invidious.svg;
                definedAliases = [ "@i" ];
              };
            };


            force = true;
            default = "SearXNG";
          };
        };

        other = {
          id = 1;
        };
      };
    };
  };
}

