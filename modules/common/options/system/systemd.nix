_:

{
  systemd.services = {
    # Unconditionally disable this
    # Removes the time in the startup where the system waits for a connection
    NetworkManager-wait-online.enable = false;
  };
}
