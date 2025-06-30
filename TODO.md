# TODO

## System config maintenance

### Modules

Right now it's an open secret that all the modules have defaults ideal for the target `terra`. Should probably look into further distinction between options and defaults.

Should also just reconsider, rename and reorganize in general.

A nice way of tackling "presets": https://github.com/diogotcorreia/dotfiles/tree/add670c4d5043a1f1ec33a4e6fa62d3f62ca46a0 (under "profiles")

### Lib

Using `myLib` feels awkward. There's a "lib" option built into the nixpkgs modules (`config.lib`) that might just do it. Or otherwise a namespace in `lib`.

### Host Init

Replace the current fanciness with better fanciness. Consider [`flake-parts`](https://github.com/hercules-ci/flake-parts)+[`nix-systems`](https://github.com/nix-systems) while we're at it

### Docs

Clean up README, get a docs folder for collecting documentation/links/snippets so that I don't have to remember it all, because something *will* get forgotten.

## [Stylix](https://github.com/danth/stylix)

Should probably explore it to better manage themes at some point

## [Commitlint](https://commitlint.js.org/)

Could help with ensuring commit messages are well made, since I'm going down this rabbit hole

## Security

Everything should be treated as a template, with adjustments made for personal use.

Efforts are spread pretty thin, which doesn't really help when you need a "little of every layer" to truly secure things.

There's some SELinux work out there, but it seems like that'll have to wait. AppArmor [might just work better](https://github.com/NixOS/nixpkgs/pull/396168#issuecomment-2783463970) ([Repo](https://git.grimmauld.de/Grimmauld/grimm-nixos-laptop/src/branch/main/hardening)).

- [`pkgs/top-level/config.nix: add selinux support`](<https://github.com/NixOS/nixpkgs/pull/396168>) (supersedes [`Provide SELinux support for Nix`](https://github.com/NixOS/nix/pull/2670))
- [`nixos/selinux: init`](https://github.com/NixOS/nixpkgs/pull/396177)

There's also the [`hardened`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/profiles/hardened.nix) profile, but that's [being deprecated](https://github.com/NixOS/nixpkgs/pull/383438) and certainly has [its fair share of issues](https://discourse.nixos.org/t/proposal-to-deprecate-the-hardened-profile/63081/5).

### Misc other sources

- <https://xeiaso.net/blog/paranoid-nixos-2021-07-18/> (Probably outdated)
- [`nix-mineral`](https://github.com/cynicsketch/nix-mineral/blob/main/nix-mineral.nix) - The `nix-mineral.nix` file has pretty good docs on more resources. Should eventually explicitly note them.
- Plenty of work by other users in their personal configs.

Many more NixOS agnostic manuals: Debian hardening, Kicksecure, that one NSA list, madaidans, etc.

### Hardened things

There's `linux_hardened` and `hardened_malloc`. The former is usually quite behind on updates in NixOS and the latter may just break the system.

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
