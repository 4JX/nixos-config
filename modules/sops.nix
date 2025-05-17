# Import module specific secrets via a pattern like https://github.com/Mic92/sops-nix/issues/378#issuecomment-2068820729
{
  self,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:

let
  # keyFile = config.sops.age.keyFile;
  # missingKeyFile = !(builtins.pathExists keyFile);
  cfg = config.ncfg.sops;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  options.ncfg.sops = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable SOPS.";
    };

    secretsPath = lib.mkOption {
      type = lib.types.path;
      default = "${self}/secrets";
      description = "The folder where the secrets are stored.";
    };
  };

  config = lib.mkIf cfg.enable {
    # warnings = lib.optionals missingKeyFile [ "SOPS: Populate the keyfile over at ${keyFile} to be able to decrypt secrets" ];
    lib.sops = rec {
      mkSecretsPath = path: cfg.secretsPath + path;
      mkHostPath = path: mkSecretsPath ("/hosts/${config.networking.hostName}/" + path);
    };

    sops = {
      defaultSopsFile = config.lib.sops.mkHostPath "secrets.yaml";
      # age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      age = {
        # ? Maybe better to have it placed somewhere else
        # inherit keyFile;
        # generateKey = true;
      };
    };

    environment.systemPackages =
      let
        sops-codium = pkgs.writeShellScriptBin "sops-codium" ''
          export EDITOR="${pkgs.vscodium}/bin/codium --wait"
          sops "$@"
        '';
      in
      with pkgs;
      [
        sops
        age
        sops-codium
      ];

    # services.openssh = {
    #   enable = true;
    #   hostKeys = lib.mkForce [
    #     {
    #       path = "/etc/ssh/ssh_host_ed25519_key";
    #       type = "ed25519";
    #     }
    #   ];
    # };
  };
}
