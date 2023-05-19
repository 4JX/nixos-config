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
          # (unstable.gnomeExtensions.gtk4-desktop-icons-ng-ding.overrideAttrs (_: {
          #   postPatch = ''
          #     for file in app/*.js; do
          #       substituteInPlace $file --replace "gjs" "${gjs}/bin/gjs"
          #     done
          #   '';
          # }))
          p.gnomeext.gnomeExtensions.easyeffects-preset-selector
          # gnomeExtensions.easyeffects-preset-selector
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
