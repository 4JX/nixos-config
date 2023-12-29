{ pkgs, lib, myLib, inputs, osConfig, ... }:

let
  cfg = osConfig.ncfg.DE.gnome;

  extensions = import ./list.nix { inherit pkgs lib inputs; };
  mapDconfSettings =
    builtins.map
      (e:
        {
          "org/gnome/shell/extensions/${e.package.extensionPortalSlug}" = e.dconfSettings;
        }
      )
      extensions;
in
lib.mkIf cfg.enable {
  home.packages = builtins.map (e: e.package) extensions;

  # Use dconf watch / to record changes
  # Use dconf2nix to get an idea of how to format the changes
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      disabled-extensions = [ ];

      # `gnome-extensions list` for a list
      enabled-extensions =
        let
          enabled = builtins.filter (e: !(e.disable or false)) extensions;
        in
        builtins.map (e: e.package.extensionUuid) enabled;
    };
  } // myLib.recursiveMergeAttrs mapDconfSettings;
}
