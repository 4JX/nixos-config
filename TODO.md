# TODO

## System config maintenance

### pkgs

Should probably automate the importing of packages based on the filename and sprinkle in some other fanciness. Gerg-L has a wonderful `mkPackages` for that.

### Modules

Right now it's an open secret that all the modules have defaults ideal for the target `terra`. Should probably look into further distinction between options and defaults.

Should also just reconsider, rename and reorganize in general.

### Lib

Using `myLib` feels awkward. There's a "lib" option built into the nixpkgs modules (`config.lib`) that might just do it. Or otherwise a namespace in `lib`.

### ncfg

The "`ncfg`" namespace name is eeh. `modules` or `local` should work better.

### Host Init

Replace the current fanciness with better fanciness. Consider [`flake-parts`](https://github.com/hercules-ci/flake-parts)+[`nix-systems`](https://github.com/nix-systems) while we're at it

### Docs

Clean up README, get a docs folder for collecting documentation/links/snippets so that I don't have to remember it all, because something *will* get forgotten.

## [Stylix](https://github.com/danth/stylix)

Should probably explore it to better manage themes at some point

## [Commitlint](https://commitlint.js.org/)

Could help with ensuring commit messages are well made, since I'm going down this rabbit hole

## Low Priority

### Portmaster

Find some way to package portmaster, most viable solution is probably an FHSEnv to let it do its auto-update shenanigans in peace

Blocked by:

- <https://github.com/NixOS/nixpkgs/issues/42117>
- <https://github.com/NixOS/nixpkgs/pull/231673>

Or some fancier way of giving portmaster-core and co. perms to do stuff inside the wrapper

## Codeium

Should not be using nix-ld as a hack, see about implementing this:

<https://github.com/NixOS/nixpkgs/blob/963540ad3515e23fe5016eba9ad81235a1d229f0/pkgs/by-name/co/codeium/package.nix#L59>

Though apparently there's some hash checking. Guessing one would need to patch the extension, but that's probably impossible since it's closed source. How does Copilot do it?
