{
  lib,
  myLib,
  config,
  ...
}:

let
  cfg = config.local.DE.gnome;

  inherit (cfg) extensions;

  # https://gjs.guide/extensions/overview/anatomy.html#settings-schema
  dconfPathFromPackage =
    extension:
    let
      formatPath = p: (builtins.replaceStrings [ "." ] [ "/" ]) p;
    in
    lib.pipe extension [
      (e: e.package)
      (p: "${p}/share/gnome-shell/extensions/${p.extensionUuid}/metadata.json")
      builtins.readFile
      builtins.fromJSON
      (
        json:
        if
          (builtins.hasAttr "settings-schema" json)
        # This is specified by the developer
        then
          (formatPath json.settings-schema)
        # If that doesn't exist, guess the location based on the UUID
        else
          (dconfPathFromUUID extension)
      )
    ];

  # https://gjs.guide/extensions/overview/anatomy.html#uuid
  dconfPathFromUUID =
    extension:
    lib.pipe extension [
      (e: e.package)
      (p: builtins.elemAt (builtins.split "@" p.extensionUuid) 0)
      (u: "org/gnome/shell/extensions/${u}")
    ];

  mapDconfSettings = builtins.map (
    e:
    let
      dconfPath = e: e.dconfPath or (dconfPathFromPackage e);
    in
    {
      "${dconfPath e}" = e.dconfSettings;
    }
  ) extensions;
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
          enabled = builtins.filter (e: e.enable) extensions;
        in
        builtins.map (e: e.package.extensionUuid) enabled;
    };
  } // myLib.recursiveMergeAttrs mapDconfSettings;
}
