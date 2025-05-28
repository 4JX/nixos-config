# https://github.com/NotAShelf/nyx/blob/44ff2682f1df31bb84d0cbc6fe9be586f9cb8bb7/modules/extra/shared/nixos/comma/default.nix

{
  config,
  lib,
  pkgs,
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

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.comma.override { nix-index-unwrapped = config.programs.nix-index.package; };
      defaultText = lib.literalExpression "pkgs.comma.override { nix-index-unwrapped = config.programs.nix-index.package; }";
      description = "Package providing the `comma` tool.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    programs = {
      # Keeps the comma database in check
      nix-index-database.comma.enable = true;

      # Depends on a nix-channel database, replace with
      # nix-index instead, which mostly works the same
      command-not-found.enable = lib.mkForce false;

      nix-index.enable = true;
    };
  };
}
