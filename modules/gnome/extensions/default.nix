{ primaryUser, p, ... }:

{
  home-manager.users.${primaryUser} = { pkgs, lib, ... }:
    let
      extensions = import ./list.nix { inherit pkgs lib; };
      mapDconfSettings =
        builtins.map
          (e:
            {
              "org/gnome/shell/extensions/${e.package.extensionPortalSlug}" = e.dconfSettings;
            }
          )
          extensions;
      recursiveMergeAttrs = lib.fold lib.recursiveUpdate { };
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
          (p.gnomeext.gnomeExtensions.gtk4-desktop-icons-ng-ding.override
            { version = "40"; sha256 = "sha256-CwqkIaGHTLu602ZtQPERsdt0HfHUa161G+JcMAtuH7Y="; })
        ] ++ builtins.map (e: e.package) extensions;

      # Use dconf watch / to record changes
      # Use dconf2nix to get an idea of how to format the changes
      dconf.settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;

          disabled-extensions = [ ];

          # `gnome-extensions list` for a list
          enabled-extensions = builtins.map (e: e.package.extensionUuid) extensions;
        };
      } // recursiveMergeAttrs mapDconfSettings;
    };

  users.users.${primaryUser} = {
    extraGroups = [ "input" ]; # Needed for gestures.
  };
}
