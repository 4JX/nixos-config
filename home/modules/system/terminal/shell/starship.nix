{ ... }:

{
  config = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        character = {
          success_symbol = "[»](bold green)";
          error_symbol = "[×](bold red) ";
        };

        git_status = {
          ahead = "↑";
          behind = "↓";
          diverged = "↕";
          modified = "!";
          staged = "±";
          renamed = "→";
        };
      };
    };
  };
}
