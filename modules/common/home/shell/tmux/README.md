# tmux

Shared Home Manager configuration for NixOS hosts and standalone Linux/nealbox
(not the installer ISO). Fish and Bash start or attach to `main`
automatically; Zsh does too if enabled through Home Manager. Panes use the
account's login shell, not a hardcoded Fish/Bash path.

Startup requires an interactive terminal and skips shells already inside tmux
and `TERM=dumb`. Non-interactive SSH commands and scripts are unaffected.
Detach returns to the outer shell; opening another terminal attaches again.
Use `NEALOS_NO_TMUX=1 fish` (or `bash`/`zsh`) to open a shell without auto-start.

## Keys

The prefix is **Ctrl-a**; release it before pressing the next key.

| Key after prefix | Action |
| --- | --- |
| `c` | New window in the current directory |
| `_` | Split side by side (vertical divider) in the current directory |
| `-` | Split top/bottom (horizontal divider) in the current directory |
| `h j k l` / `H J K L` | Select / resize a pane |
| `1` ... `9` | Select a window (numbering starts at 1) |
| `z` | Toggle pane zoom |
| `[` | Vi copy mode (`Space` to select, `Enter` to copy, `q` to leave) |
| `]` | Paste the tmux buffer |
| `d` | Detach without stopping processes |
| `f` | lazy-tmux picker: switch live sessions or restore a saved session |
| `Ctrl-s` | Save all sessions with lazy-tmux |
| `?` | List bindings |

Mouse selection, pane resizing, and scrolling are enabled. The copy buffer is
tmux's buffer; system clipboard integration depends on the terminal.

## Appearance

[theme.nix](./theme.nix) gives tmux a jade status rail using the shared build-time
palette, like Starship:

- A framed session badge and numbered window tabs; the active tab gets a solid
  accent tile. Background activity/bell flags appear as `+` / `!` when reported.
- A clock, with hostname at 110+ columns and date at 140+ columns, leaving more
  room for windows on small terminals.
- `KEY` after Ctrl-a, `COPY` in pane modes (including copy mode), and `ZOOM`
  while zoomed. The active pane border also changes accent while a key is pending.
- Slim pane headers with pane number, running command, and directory basename,
  shown only in windows with multiple panes.
- Matching selection, messages, menus, and rounded popup borders.

Unicode block/line separators need no Nerd Font. Application backgrounds remain
untouched; inactive panes are not dimmed. Everything is drawn by tmux itself:
there are no theme plugins or background polling commands.

Colours update after rebuilding and reloading tmux, not when switching Noctalia
palettes at runtime. True colour is enabled for xterm-compatible, foot,
Alacritty, and nested tmux terminals; other terminals retain their capabilities.
The lazy-tmux picker draws its own contents; tmux themes its surrounding popup.

## Session workflows

The shell alias `ltm` runs `lazy-tmux` in Fish, Bash, and Home Manager-enabled Zsh.
Native Fish completions are bundled with the package and also
work through `ltm`. They suggest subcommands, command-specific flags, config
paths, and fixed values such as agent names. Session names are entered manually.
The definitions in [completions/](./completions/) track the pinned CLI version.

```sh
tmux new-session -s project       # from outside tmux
tmux new-window -n editor        # from inside tmux
tmux list-sessions
tmux switch-client -t project    # switch from inside tmux
tmux attach-session -t project   # attach from outside tmux

lazy-tmux save --all             # snapshot before logout/reboot
lazy-tmux list                   # list saved sessions
lazy-tmux picker                 # choose one to restore on demand
lazy-tmux sleep --session project
lazy-tmux wakeup --session project
```

Saving is manual by default. For periodic snapshots, run
`lazy-tmux daemon --interval 3m` in a pane (Ctrl-c stops it). Add `--scrollback`
to save/daemon commands to persist terminal output; it is off by default
because output may contain sensitive data.

Snapshots live under `~/.local/share/lazy-tmux` by default. They survive a tmux
restart, not deletion of a container's home or reboot of a non-persistent ISO.
Restoring recreates layouts, directories, and commands, not live process memory
or unsaved editor buffers. Commands may run again: restore only trusted
snapshots. Restoring is explicit; starting a shell never replays saved commands.

Configuration is managed by Nix: do not run `lazy-tmux setup >> ~/.tmux.conf`.
After a Home Manager switch, reload with
`tmux source-file ~/.config/tmux/tmux.conf` (or the corresponding
`$XDG_CONFIG_HOME` path). The pinned [lazy-tmux](https://github.com/alchemmist/lazy-tmux)
source package is in [package.nix](./package.nix), until available in nixpkgs.
