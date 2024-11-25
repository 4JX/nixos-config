{ ... }:

{
  # Enable the X11 windowing system.
  services = {
    displayManager.defaultSession = "gnome";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb.layout = "es";
    };
  };
}
