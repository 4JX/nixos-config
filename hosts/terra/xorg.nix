{ pkgs, ... }:

# let
#   offloadEnabled = config.hardware.nvidia.prime.offload.enable;
# in
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    # Configure keymap in X11
    layout = "es";

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    # Enable KDE
    desktopManager.plasma5.enable = true;
    displayManager.defaultSession = "gnome";
  };

  # Conflict between KDE and GNOME
  programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";

  # Disabled from loading in nixos-hardware but not put anywhere afterwards
  boot.kernelModules = [ "amdgpu" ];

  # Broken thanks to this PR https://github.com/NixOS/nixpkgs/pull/218437
  # Which is then mirrored in nixos-hardware https://github.com/NixOS/nixos-hardware/commit/630a8e3e4eea61d35524699f2f59dbc64886357d
  # options.services.xserver.drivers will have a amdgpu entry from using the prime stuff in nixpkgs
  # Trying to orchestrate "sane defaults" is pain when you don't care to then update the prime module
  services.xserver.videoDrivers = [ "nvidia" ];

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
