{ pkgs, ... }:

{


  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;

    # https://github.com/nix-community/home-manager/issues/3965
    # https://github.com/NixOS/nixpkgs/blob/fd40cef8d797670e203a27a91e4b8e6decf0b90c/nixos/modules/programs/zsh/zsh.nix#L149-L160
    # https://github.com/nix-community/home-manager/blob/78ceec68f29ed56d6118617e9f0f588bf164067f/modules/programs/zsh.nix#L290-L306
    # When using enable = true in both nixpkgs and home-manager zsh slows down a bunch
    # Disable "initialising" completion in home-manager since it is already enabled by default
    # in nixpkgs with programs.zsh.enableCompletion (which affects enableCompletion)
    # This also removes the automatic addition of nix-zsh-completions, but it's added back anyways
    enableCompletion = false;

    shellAliases = with pkgs; {
      # MOVE THIS TO system env aliases
      eza = "${eza}/bin/eza --icons";
      scrcpy = "${scrcpy}/bin/scrcpy --bit-rate 32M --encoder 'OMX.qcom.video.encoder.avc' --window-title 'Phone' --stay-awake --turn-screen-off";
      discordrpc = "ln -sf {app/com.discordapp.Discord,$XDG_RUNTIME_DIR}/discord-ipc-0";

      # Faster navigation
      ".." = "cd ..";
      "..." = "cd ../../";
      "...." = "cd ../../../";
      "....." = "cd ../../../../";
      "......" = "cd ../../../../../";
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        src = "${pkgs.zsh-fast-syntax-highlighting}";
      }
      {
        name = "zsh-nix-shell";
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
        src = "${pkgs.zsh-nix-shell}";
      }
      {
        name = "nix-zsh-shell-completions";
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
        src = "${pkgs.nix-zsh-completions}";
      }
      {
        name = "nix-zsh-shell-completions";
        file = "share/zsh/plugins/nix/nix-zsh-completions.plugin.zsh";
        src = "${pkgs.nix-zsh-completions}";
      }
      {
        name = "zsh-autopair";
        file = "zsh-autopair.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
      }
      {
        name = "zsh-colored-man-pages";
        file = "colored-man-pages.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "ohmyzsh";
          repo = "ohmyzsh";
          rev = "d3bb52d7d825f2a6ce2e1c76ca472b05c6f27b40";
          sha256 = "sha256-087bNmB5gDUKoSriHIjXOVZiUG5+Dy9qv3D69E8GBhs=";
        };
      }
      # {
      #   name = "zsh-nix-shell";
      #   file = "nix-shell.plugin.zsh";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "chisui";
      #     repo = "zsh-nix-shell";
      #     rev = "v0.5.0";
      #     sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
      #   };
      # }
    ];
  };
}
