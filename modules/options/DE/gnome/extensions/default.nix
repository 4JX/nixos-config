{ mainUser, p, myLib, ... }:

{
  home-manager.users.${mainUser} = { pkgs, lib, ... }:
    let
      extensions = import ./list.nix { inherit pkgs lib p; };
      mapDconfSettings =
        builtins.map
          (e:
            {
              "org/gnome/shell/extensions/${e.package.extensionPortalSlug}" = e.dconfSettings;
            }
          )
          extensions;
    in
    {
      home.packages =
        with pkgs; [
          gnome-extension-manager
          dconf2nix
          # (gnomeExtensions.gtk4-desktop-icons-ng-ding.overrideAttrs (_: {
          #   patches = [
          #     (substituteAll {
          #       inherit gjs util-linux xdg-utils;
          #       util_linux = util-linux;
          #       xdg_utils = xdg-utils;
          #       src = ./desktopicons.patch;
          #       nautilus_gsettings_path = "${glib.getSchemaPath gnome.nautilus}";
          #     })
          #   ];
          # }))
        ] ++ builtins.map (e: e.package) extensions;

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
    };

  users.users.${mainUser} = {
    extraGroups = [ "input" ]; # Needed for gestures.
  };
}
