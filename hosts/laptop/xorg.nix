{ ... }:

{
  # Disabled from loading in nixos-hardware but not put anywhere afterwards
  boot.kernelModules = [ "amdgpu" ];

  # Broken thanks to this PR https://github.com/NixOS/nixpkgs/pull/218437
  # Which is then mirrored in nixos-hardware https://github.com/NixOS/nixos-hardware/commit/630a8e3e4eea61d35524699f2f59dbc64886357d
  # options.services.xserver.drivers will have a amdgpu entry from using the prime stuff in nixpkgs-hardware
  # Trying to orchestrate "sane defaults" is pain when you don't care to then update the prime module
  services.xserver.videoDrivers = [ "nvidia" ];

  services.xserver.exportConfiguration = true;
}
