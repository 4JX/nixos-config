# TODO

- Upstream trayIndicator fix

## Portmaster

Find some way to package portmaster, most viable solution is probably an FHSEnv to let it do its auto-update shenanigans in peace

Blocked by:

- <https://github.com/NixOS/nixpkgs/issues/42117>
- <https://github.com/NixOS/nixpkgs/pull/231673>

Or some fancier way of giving portmaster-core and co. perms to do stuff inside the wrapper
