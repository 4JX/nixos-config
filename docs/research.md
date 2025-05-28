# Research

Misc notes for fixes and other things I don't want to lose

## Patching `nixpkgs`

<https://github.com/NixOS/nixpkgs/pull/142273#issuecomment-948225922>

<https://ertt.ca/nix/patch-nixpkgs/>

<https://github.com/NixOS/nix/issues/3920#issuecomment-681187597>

## Patching GNOME extensions

The entrypoint for a patch is [extensionOverrides.nix](<https://github.com/NixOS/nixpkgs/blob/master/pkgs/desktops/gnome/extensions/extensionOverrides.nix>). The file also provides many good examples to tackle common issues.

You probably want one of the [replacement](https://nixos.org/manual/nixpkgs/stable/#sec-build-support) functions. Schema issues need a few extra lines.

Older reference examples:

- <https://github.com/NixOS/nixpkgs/pull/233642> (Old PR, use `replaceVars` instead)
- <https://github.com/NixOS/nixpkgs/blob/7bb8f05f12ca3cff9da72b56caa2f7472d5732bc/pkgs/desktops/gnome-3/extensions/gsconnect/default.nix#L21>
- <https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-common-issues-unwrappable-package-gsettings-c>

## Extracting data for declarative firefox search engines

Use [dejsonlz4](<https://github.com/avih/dejsonlz4>) to extract your current settings, and tweak it to fit `home-manager`'s [`programs.firefox.profiles.<name>.search`](<https://nix-community.github.io/home-manager/options.xhtml#opt-programs.firefox.profiles._name_.search>)

## ZSH is slow to start

When using enable = true in both nixpkgs and home-manager zsh slows down a bunch due to duplicate calls to `compinit`. In my case I just disable the `home-manager` option.

<https://github.com/nix-community/home-manager/issues/3965>

## Fix home-manager's home.sessionVariables not being sourced on DE's

<https://rycee.gitlab.io/home-manager/index.html#_why_are_the_session_variables_not_set>

<https://github.com/hpfr/system/blob/a108a5ebf3ffcee75565176243936de6fd736142/profiles/system/base.nix#L12-L16>

<https://github.com/nix-community/home-manager/issues/1011>

## Microsoft fonts

For when you want to sell your soul to the devil

<https://github.com/spikespaz/dotfiles/tree/eedd610fc2125567e7f7bd7471042ab7e24efe97/packages/ttf-ms-win11>

# Old

These are probably not relevant anymore due to updates/fixes, but keep them just in case

## Flatpak access to fonts

<https://github.com/NixOS/nixpkgs/issues/119433>

<https://github.com/accelbread/config-flake/blob/744196b43b93626025e5a2789c8700a5ec371aad/nix/nixosModules/bind-fonts-icons.nix#L9>

# Non Nix specific

## AMD Pstate EPP

Interesting options to play with can be found in

```sh
/sys/devices/system/cpu/cpu{num}/cpufreq/
```

Kernel 6.4 apparently brings a new guided mode, should see how that behaves

## Power profiles daemon

`powerprofilesctl` - `launch` is an interesting subcommand
