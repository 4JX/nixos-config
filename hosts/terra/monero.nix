{ pkgs, ... }:

# https://github.com/headblockhead/nixos/blob/82707e42c09ad0bdc0cd898bb203a46e088b7cc5/modules/nixos/p2pool.nix
# ./monerod --zmq-pub tcp://127.0.0.1:18083 --out-peers 32 --in-peers 64 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist

{
  services.monero = {
    enable = true;
    dataDir = "/var/lib/monero";
    priorityNodes = [
      "nodes.hashvault.pro:18080"
      "p2pmd.xmrvsbeast.com:18080"
    ];
    limits = {
      # 1048576 kB/s = 1GB/s
      # 10485760 kB/s = 10GB/s
      upload = 10485760;
      download = -1;
      # download = 10485760;
    };
    extraConfig = ''
      out-peers=64              # Faster sync
      in-peers=1024             # Default is unlimited, but we limit it to 1024
      zmq-pub=tcp://127.0.0.1:18084
    '';
  };
  environment.systemPackages = with pkgs; [
    xmrig
    p2pool
    monero-gui
    monero-cli
  ];

  # systemd.services.p2pool = {
  #   description = "Decentralized pool for Monero mining";
  #   after = [ "monero.service" "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.unstable.p2pool}/bin/p2pool --mini --host 127.0.0.1 --rpc-port 18081 --zmq-port 18084 --wallet CHANGEME --stratum 0.0.0.0:3333 --p2p 0.0.0.0:37889";
  #     Restart = "always";
  #     RestartSec = 10;
  #   };
  # };
}
