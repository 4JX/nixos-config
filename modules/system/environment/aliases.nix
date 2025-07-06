{ pkgs, ... }:

{
  environment.shellAliases = {
    update-config = "nixos-rebuild --sudo switch -L && ${pkgs.libnotify}/bin/notify-send \"System Updated\"";
  };
}
