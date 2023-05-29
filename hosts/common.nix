{ pkgs, primaryUser, lib, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/Madrid";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "es";
    #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    btop
    cudatoolkit # nvidia-smi
    iftop
    pciutils # lspci
    killall
    exa
    bat
    cmake
    gcc
    efibootmgr
    nvtop
    (inxi.override
      { withRecommends = true; }) # inxi -Fazy
    ripgrep # Faster grep
    ripgrep-all # Wrapper arround ripgrep for convenience universal searching across a ton of filetypes
    fd # Better find

    # Nix stuffs
    nil # Nix language server
    nixpkgs-fmt
    nixos-option
    deadnix
    statix
    nix-tree # Scan current system / derivations for what-why-how depends
  ];

  # Fix home-manager's home.sessionVariables not being sourced on DE's
  # https://rycee.gitlab.io/home-manager/index.html#_why_are_the_session_variables_not_set
  # https://github.com/hpfr/system/blob/a108a5ebf3ffcee75565176243936de6fd736142/profiles/system/base.nix#L12-L16
  # https://github.com/nix-community/home-manager/issues/1011
  environment.extraInit =
    let
      sourceForUser = (user: ''
        if [ "$(id -un)" = "${user}" ]; then
          . "/etc/profiles/per-user/${user}/etc/profile.d/hm-session-vars.sh"
        fi
      '');
    in
    lib.concatLines (builtins.map sourceForUser [ primaryUser ]);

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}

