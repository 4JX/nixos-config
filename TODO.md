# TODO

- Fix trayIndicator when executing steam

```log
May 25 01:41:21 nixos .gnome-shell-wr[2918]: JS ERROR: GLib.SpawnError: Failed to execute child process “/bin/bash” (No such file or directory)
````

## Pstate

‌<https://libreddit.kylrth.com/r/archlinux/comments/1381g2g/amd_pstate_epp_scaling_driver_available_with/>

Maybe after pstate matures, consider using it. Currently gives worse battery life (27-5-2023)

## Portmaster

Find some way to package portmaster, most viable solution is probably an FHSEnv to let it do its auto-update shenanigans in peace

Blocked by:

- <https://github.com/NixOS/nixpkgs/issues/42117>
- <https://github.com/NixOS/nixpkgs/pull/231673>

Or some fancier way of giving portmaster-core and co. perms to do stuff inside the wrapper
