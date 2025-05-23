{
  lib,
  config,
  pkgs,
  options,
  ...
}:

let
  cfg = config.local.wireguard.server;
  # This is ugly, ignore it
  originalTypes = options.networking.wireguard.interfaces.type.getSubOptions [ ];
  peerType = originalTypes.peers.type;
in
{
  options.local.wireguard.server = {
    enable = lib.mkEnableOption "the wireguard server";
    interfaces = {
      external = lib.mkOption {
        type = lib.types.str;
        default = "eth0";
        description = "The interface to use as the external interface.";
      };
      internal = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
        description = "The interface to use as the internal interface.";
      };
    };
    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 51820;
      description = "The port to listen on.";
    };
    peers = lib.mkOption {
      default = [ ];
      description = "Peers linked to the interface.";
      # Not going to bother redefining the full type
      # https://github.com/NixOS/nixpkgs/blob/3566ab7246670a43abd2ffa913cc62dad9cdf7d5/nixos/modules/services/networking/wireguard.nix#L213
      # type = with lib.types; listOf attrs;
      type = peerType;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.wg-server-private-key = { };
    # Very heavily copied from the wiki

    # enable NAT
    networking.nat.enable = true;
    networking.nat.externalInterface = cfg.interfaces.external;
    networking.nat.internalInterfaces = [ cfg.interfaces.internal ];

    networking.firewall = {
      allowedUDPPorts = [ cfg.listenPort ];
    };

    networking.wireguard.enable = true;
    networking.wireguard.interfaces = {
      # "wg0" is the network interface name. You can name the interface arbitrarily.
      ${cfg.interfaces.internal} = {
        # Determines the IP address and subnet of the server's end of the tunnel interface.
        ips = [ "10.100.0.1/24" ];

        # The port that WireGuard listens to. Must be accessible by the client.
        inherit (cfg) listenPort;

        # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
        # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${cfg.interfaces.external} -j MASQUERADE
        '';

        # This undoes the above command
        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${cfg.interfaces.external} -j MASQUERADE
        '';

        # Path to the private key file.
        privateKeyFile = config.sops.secrets.wg-server-private-key.path;

        inherit (cfg) peers;
      };
    };
  };
}
