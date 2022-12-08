{ primaryUser, ... }:



{
  networking.networkmanager.enable = true;

  users.users.${primaryUser}.extraGroups = [ "networkmanager" ];
}
