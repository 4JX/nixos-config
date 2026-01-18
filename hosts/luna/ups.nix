{ config, ... }:

let
  upsName = "eaton-ellipse";
in
{
  sops.secrets."nut-admin-pass" = {
    # mode = "0400";
  };

  power.ups = {
    enable = true;
    mode = "standalone";

    # Driver (ups.conf)
    ups.${upsName} = {
      driver = "usbhid-ups";
      port = "auto";
      description = "Eaton Ellipse Pro 1600 (USB)";

      directives = [
        "vendorid = 0463"
        "productid = FFFF"

        # Base shutdown decision on charge/runtime thresholds
        # "ignorelb"

        # Shut down at 20% battery
        # "override.battery.charge.low = 20"

        # Also shutdown if runtime gets too low
        # "override.battery.runtime.low = 300"
      ];
    };

    # Listen only locally (upsd.conf)
    upsd.listen = [
      {
        address = "127.0.0.1";
        port = 3493;
      }
      # {
      #   address = "::1";
      #   port = 3493;
      # }
    ];

    # Users + upsmon (upsd.users + upsmon.conf)
    users."nut-admin" = {
      passwordFile = config.sops.secrets."nut-admin-pass".path;
      upsmon = "primary";
    };

    upsmon.monitor.${upsName} = {
      system = "${upsName}@localhost";
      powerValue = 1;
      user = "nut-admin";
      passwordFile = config.sops.secrets."nut-admin-pass".path;
      type = "primary";
    };
  };
}
