{ ... }:

{
  # Open up a port for qbittorrent
  networking.firewall =
    let
      port = 58902;
    in
    {
      allowedTCPPorts = [ port ];
      allowedUDPPorts = [ port ];
    };
}
