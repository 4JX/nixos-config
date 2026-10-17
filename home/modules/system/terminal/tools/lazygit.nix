{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.programs.lazygit;

  delta = lib.getExe pkgs.delta;
  difft = lib.getExe pkgs.difftastic;
  less = lib.getExe pkgs.less;

  editor = "codium";

  gitPathArg = "{{ if .SelectedPath }}-- {{ .SelectedPath | quote }}{{ else }}-- .{{ end }}";
in
{
  options.local.programs.lazygit.enable = lib.mkEnableOption "lazygit" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.delta
      pkgs.difftastic
      pkgs.less
      pkgs.semgrep
    ];

    programs.lazygit = {
      enable = true;

      settings = {
        os = {
          edit = "${editor} --reuse-window -- {{filename}}";
          editAtLine = "${editor} --reuse-window --goto {{filename}}:{{line}}";
          editAtLineAndWait = "${editor} --reuse-window --wait --goto {{filename}}:{{line}}";
          openDirInEditor = "${editor} --reuse-window -- {{dir}}";
        };

        gui = {
          sidePanelWidth = 0.25;

          nerdFontsVersion = "3";

          fileTreeSortOrder = "foldersFirst";

          showNumstatInFilesView = true;
          showBranchCommitHash = true;
          showDivergenceFromBaseBranch = "arrowAndNumber";

          shortTimeFormat = "15:04";

          commitAuthorShortLength = 8;
        };

        git = {
          autoStageResolvedConflicts = true;

          diffRenderers = [
            {
              colorArg = "always";
              command = ''${delta} --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"'';
            }
            {
              type = "extDiff";
              command = "${difft} --color=always --display=inline";
            }
          ];
        };

        customCommands = [
          {
            key = "<ctrl-x>";
            context = "files";
            description = "Delta side-by-side diff";
            command = ''
              git diff --color=always --no-ext-diff HEAD ${gitPathArg} |
                ${delta} --dark --side-by-side --line-numbers --paging=always
            '';
            output = "terminal";
          }
          {
            key = "<ctrl-d>";
            context = "files";
            description = "Difftastic side-by-side diff";
            command = ''
              env GIT_EXTERNAL_DIFF="${difft} --color=always --display=side-by-side" \
                git diff --ext-diff HEAD ${gitPathArg} |
                ${less} -R
            '';
            output = "terminal";
          }
        ];
      };
    };
  };
}
