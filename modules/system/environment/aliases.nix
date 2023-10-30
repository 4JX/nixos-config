{ pkgs, ... }:

{
  environment.shellAliases = {
    update-config = "nixos-rebuild --use-remote-sudo switch -L && ${pkgs.libnotify}/bin/notify-send \"System Updated\"";
  };
}
