{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.ncfg.wireguard.client;
  # This is ugly, ignore it
  originalTypes = options.networking.wireguard.interfaces.type.getSubOptions [ ];
  peerType = originalTypes.peers.type;
in
{
  options.ncfg.wireguard.client = {
    enable = lib.mkEnableOption "the wireguard client";
    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "The interface to use for the client.";
    };
    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
      description = "The port to listen on.";
    };
    peers = lib.mkOption {
      default = [ ];
      description = "Server peers.";
      type = peerType;
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets.wg-client-private-key = { };

    networking.firewall = {
      allowedUDPPorts = [ cfg.listenPort ]; # Clients and peers can use the same port, see listenport
    };
    # Enable WireGuard
    networking.wireguard.enable = true;
    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      ${cfg.interface} = {
        # Determines the IP address and subnet of the client's end of the tunnel interface.
        ips = [ "10.100.0.2/24" ];
        inherit (cfg) listenPort; # to match firewall allowedUDPPorts (without this wg uses random port numbers)

        # Path to the private key file.
        privateKeyFile = config.sops.secrets.wg-client-private-key.path;

        inherit (cfg) peers;
      };
    };
  };
}
