# Resources dump

Also scattered throughout the code via comments

### TODO

- Patch the desktop icons (gtk4/normal) extensions and comment on <https://github.com/NixOS/nixpkgs/issues/154944> <https://gitlab.com/smedius/desktop-icons-ng/-/issues/22>
Fix trayIndicator
May 25 01:41:21 nixos .gnome-shell-wr[2918]: JS ERROR: GLib.SpawnError: Failed to execute child process “/bin/bash” (No such file or directory)
                                             _isUsingQt@/etc/profiles/per-user/infinity/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/AppManager.js:140:36
                                             _openApplication@/etc/profiles/per-user/infinity/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/AppManager.js:110:13
                                             leftClick@/etc/profiles/per-user/infinity/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/AppManager.js:20:18
                                             addIcon/<@/etc/profiles/per-user/infinity/share/gnome-shell/extensions/trayIconsReloaded@selfmade.pl/TrayIndicator.js:85:24

### Misc

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

- <https://github.com/NixOS/nixpkgs/blob/7bb8f05f12ca3cff9da72b56caa2f7472d5732bc/pkgs/desktops/gnome-3/extensions/gsconnect/default.nix#L21>
- <https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-common-issues-unwrappable-package-gsettings-c>

### Extracting data for declarative firefox search engines

<https://github.com/avih/dejsonlz4>

### Flatpak access to fonts

<https://github.com/NixOS/nixpkgs/issues/119433>
<https://github.com/accelbread/config-flake/blob/744196b43b93626025e5a2789c8700a5ec371aad/nix/nixosModules/bind-fonts-icons.nix#L9>
