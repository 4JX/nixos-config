{ pkgs, ... }:

# let
#   offloadEnabled = config.hardware.nvidia.prime.offload.enable;
# in
{
  # Enable the X11 windowing system.
  services = {
    displayManager.defaultSession = "gnome";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable KDE
    desktopManager.plasma6.enable = true;

    xserver = {
      enable = true;

      # Configure keymap in X11
      xkb.layout = "es";
    };
  };

  # Conflict between KDE and GNOME
  programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  services.xserver.exportConfiguration = true;

  # Add config on top of nixos-hardware
  # services.xserver.drivers = lib.optionals offloadEnabled [
  #   {
  #     driverName = "amdgpu";
  #     name = "amdgpu";
  #     modules = with pkgs; [ xorg.xf86videoamdgpu ];
  #     display = true;
  #     deviceSection = ''
  #       Option "VariableRefresh" "true"
  #       Option "TearFree" "1"
  #       Option "DRI" "3"
  #     '';
  #   }
  # ];
}
