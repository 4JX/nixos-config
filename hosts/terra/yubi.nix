{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # yubikey-manager
    yubioath-flutter
  ];

  programs.yubikey-manager = {
    enable = true;
  };
}
