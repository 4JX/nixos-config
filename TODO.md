# TODO

- Switch back to unstable for extensions when PR lands

<https://nixpk.gs/pr-tracker.html?pr=235948>

- Fix trayIndicator when executing steam

```log
May 25 01:41:21 nixos .gnome-shell-wr[2918]: JS ERROR: GLib.SpawnError: Failed to execute child process “/bin/bash” (No such file or directory)
````

## Portmaster

Find some way to package portmaster, most viable solution is probably an FHSEnv to let it do its auto-update shenanigans in peace

Blocked by:

- <https://github.com/NixOS/nixpkgs/issues/42117>
- <https://github.com/NixOS/nixpkgs/pull/231673>

Or some fancier way of giving portmaster-core and co. perms to do stuff inside the wrapper
