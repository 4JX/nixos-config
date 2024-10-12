# TODO

## Codeium

Should not be using nix-ld as a hack, see about implementing this:

<https://github.com/NixOS/nixpkgs/blob/963540ad3515e23fe5016eba9ad81235a1d229f0/pkgs/by-name/co/codeium/package.nix#L59>

Though apparently there's some hash checking. Guessing one would need to patch the extension, but that's probably impossible since it's closed source. How does Copilot do it?

## [Swag](https://docs.linuxserver.io/general/swag)

Perhaps useful for when I expose homeserver things to the internet

## [Commitlint](https://commitlint.js.org/)

Could help with ensuring commit messages are well made, since I'm going down this rabbit hole

## [Stylix](https://github.com/danth/stylix)

Should probably explore it to better manage themes at some point

## Low Priority

### Portmaster

Find some way to package portmaster, most viable solution is probably an FHSEnv to let it do its auto-update shenanigans in peace

Blocked by:

- <https://github.com/NixOS/nixpkgs/issues/42117>
- <https://github.com/NixOS/nixpkgs/pull/231673>

Or some fancier way of giving portmaster-core and co. perms to do stuff inside the wrapper
