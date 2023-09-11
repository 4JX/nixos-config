{ lib, config, primaryUser, inputs, ... }:

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
    enable = lib.mkEnableOption "Enable Firefox";
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
    home-manager.users.${primaryUser} = { pkgs, ... }: {
      programs.firefox = {
        enable = true;
        profiles = {
          default = {
            extraConfig = final;
            search = {
              # Data for these is extracted from ~/.mozilla/firefox/default/search.json.mozlz4 with "nix-shell -p dejsonlz4"
              engines = {
                "Google".metaData.hidden = true;
                "Bing".metaData.hidden = true;

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
                  urls = [
                    {

                      template = "https://search.libredirect.invalid/";
                      params = [
                        { name = "q"; value = "{searchTerms}"; }
                      ];
                    }

                  ];
                  icon = ./engine-logos/libredirect.png;
                  iconMapObj = {
                    "{}" = "moz-extension://e115e8c0-56ce-4709-b20b-6185524b5fc9/assets/images/libredirect-128.png";
                  };
                  definedAliases = [ "@lb" ];
                  _extensionID = "7esoorv3@alefvanoon.anonaddy.me";
                };

                "Wikipedia (en)".metaData.alias = "@w";

                "DuckDuckGo".metaData.alias = "@ddg";

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
                      { name = "channel"; value = "22.11"; }
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
                  definedAliases = [ "@ni" ];
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
  };
}
