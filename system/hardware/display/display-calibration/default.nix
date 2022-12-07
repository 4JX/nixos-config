{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ colord-kde ];

  services.colord.enable = true;
}
