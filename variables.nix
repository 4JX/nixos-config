{ config, lib, ... }:

{
  options.cfg = {
    user = lib.mkOption {
      default = "infinity";
      type = lib.types.str;
    };
  };
}
