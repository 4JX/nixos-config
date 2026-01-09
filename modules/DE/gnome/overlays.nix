{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      # Fix suspend loop with GNOME+NVIDIA
      # https://github.com/NixOS/nixpkgs/issues/336723#issuecomment-3724194485
      # https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/merge_requests/462
      # https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/commit/44e1cc564b02349adab38e691770f13c0e09951b
      # https://github.com/GNOME/gnome-settings-daemon/commit/44e1cc564b02349adab38e691770f13c0e09951b
      gnome-settings-daemon = super.gnome-settings-daemon.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (pkgs.fetchpatch {
            url = "https://gitlab.gnome.org/GNOME/gnome-settings-daemon/-/commit/44e1cc564b02349adab38e691770f13c0e09951b.patch";
            name = "fix-gnome-sleep-loop.patch";
            hash = "sha256-hElYD91/1/LO9SaUYNZaIlzIKmOSVPVpGy9v4PwsTi4=";
          })
        ];
      });
    })
  ];
}
