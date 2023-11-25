# Resources dump

Also scattered throughout the code via comments

### Misc

<https://noogle.dev/>

<https://blog.nobbz.dev/posts/2022-09-17-callpackage-a-tool-for-the-lazy/>

### PR Tracker

<https://nixpk.gs/pr-tracker.html>

### Resolve `<nixpkgs>` and other references to the flake input

<https://ayats.org/blog/channels-to-flakes/>

### 1000 instances of nixpkgs

<https://zimbatm.com/notes/1000-instances-of-nixpkgs>

### Patching `nixpkgs`

<https://github.com/NixOS/nixpkgs/pull/142273#issuecomment-948225922>

<https://ertt.ca/nix/patch-nixpkgs/>

<https://github.com/NixOS/nix/issues/3920#issuecomment-681187597>

### Configuring GNOME declaratively

<https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/>

<https://github.com/gvolpe/dconf2nix>

### Patching GNOME extensions

<https://github.com/NixOS/nixpkgs/blob/master/pkgs/desktops/gnome/extensions/extensionOverrides.nix>

Specifically not finding other apps:

- <https://github.com/NixOS/nixpkgs/pull/233642>
- <https://github.com/NixOS/nixpkgs/blob/7bb8f05f12ca3cff9da72b56caa2f7472d5732bc/pkgs/desktops/gnome-3/extensions/gsconnect/default.nix#L21>
- <https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-common-issues-unwrappable-package-gsettings-c>

### Extracting data for declarative firefox search engines

<https://github.com/avih/dejsonlz4>

### Flatpak access to fonts

<https://github.com/NixOS/nixpkgs/issues/119433>

<https://github.com/accelbread/config-flake/blob/744196b43b93626025e5a2789c8700a5ec371aad/nix/nixosModules/bind-fonts-icons.nix#L9>

### ZSH is slow to start

When using enable = true in both nixpkgs and home-manager zsh slows down a bunch due to duplicate calls to `compinit`

<https://github.com/nix-community/home-manager/issues/3965>

### Fix home-manager's home.sessionVariables not being sourced on DE's

<https://rycee.gitlab.io/home-manager/index.html#_why_are_the_session_variables_not_set>
<https://github.com/hpfr/system/blob/a108a5ebf3ffcee75565176243936de6fd736142/profiles/system/base.nix#L12-L16>
<https://github.com/nix-community/home-manager/issues/1011>

### Command-not-found prompt + flakes

<https://blog.nobbz.dev/2023-02-27-nixos-flakes-command-not-found/>

## _Non Nix specific_

### AMD Pstate EPP

Partly controlled by `tlp` at the moment and staying that way unless ppd makes a comeback from being acrhived

Interesting options to play with can be found in

```sh
/sys/devices/system/cpu/cpu{num}/cpufreq/
```

Kernel 6.4 apparently brings a new guided mode, should see how that behaves

### Power profiles daemon

`powerprofilesctl` - `launch` is an interesting subcommand
