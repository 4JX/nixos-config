{ ... }:

{
  enable = true;
  # This works as expected, the ones disabled by default stay that way
  # https://github.com/dwarfmaster/arkenfox-nixos/issues/51#issuecomment-2242791297
  enableAllSections = true;
}
