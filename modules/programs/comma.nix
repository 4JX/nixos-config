# https://github.com/NotAShelf/nyx/blob/44ff2682f1df31bb84d0cbc6fe9be586f9cb8bb7/modules/extra/shared/nixos/comma/default.nix

{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.local.programs.comma;
in
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  options.local.programs.comma = {
    enable = lib.mkEnableOption "comma";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      # Installs comma wrapped with nix-index-database's small /bin index.
      nix-index-database.comma.enable = true;

      # Provides nix-locate via nix-index-database's wrapped nix-index package.
      nix-index.enable = true;
    };
  };
}
