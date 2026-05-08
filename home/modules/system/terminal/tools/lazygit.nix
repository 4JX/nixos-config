{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.local.programs.lazygit;

  sem = inputs.sem.packages.${pkgs.stdenv.hostPlatform.system}.default;

  delta = lib.getExe pkgs.delta;
  difft = lib.getExe pkgs.difftastic;
  less = lib.getExe pkgs.less;
  semExe = lib.getExe sem;

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
      sem
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

          pagers = [
            {
              colorArg = "always";
              pager = ''${delta} --dark --paging=never --line-numbers --hyperlinks --hyperlinks-file-link-format="lazygit-edit://{path}:{line}"'';
            }
            {
              pager = "${semExe} diff --patch --format terminal --color always";
              colorArg = "never";
            }
            {
              externalDiffCommand = "${difft} --color=always --display=inline";
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
