# tmux + sesh + zoxide

Shared Home Manager setup for NixOS hosts and standalone Linux/nealbox.

## Concepts

| Term | Meaning |
| --- | --- |
| Server | tmux process managing sessions |
| Session | One project |
| Window | One activity within a session |
| Pane | Things to see side by side |
| Client | Terminal attached to a session |

## Autostart

- OS terminals get their own session.
- VS Code terminals share a per-workspace session.
- Each VS Code terminal opens a new window; closing the terminal leaves that
  window running.
- Set `NEALOS_NO_TMUX=1` to disable autostart, e.g. `NEALOS_NO_TMUX=1 fish`.
- Startup skips nested tmux, non-interactive shells, and `TERM=dumb`.

**Implementation note:** the shell hook currently runs `tmux new-session -A -s
main`; it does not select per-OS-terminal or per-workspace sessions, or create a
new window per VS Code terminal.

## Keys and commands

Prefix is **Ctrl-a**; release it before pressing the next key.

| Key / command | Action |
| --- | --- |
| `prefix s` | Open sesh project picker |
| `sesh connect` | Connect to a session from a shell |
| `z <dir>` / `zi` | Jump to a directory / interactive zoxide picker |
| `prefix _` | Split side by side; use one pane for the dev server and one for a shell |
| `prefix -` | Split top/bottom |
| `prefix h/j/k/l` | Move between panes |
| `prefix H/J/K/L` | Resize a pane |
| `prefix z` | Zoom / restore current pane |
| `prefix w` | Choose a window |
| `prefix c` | New window in the current directory |
| `prefix 1` ... `prefix 9` | Select window |
| `prefix [` / `prefix ]` | Enter copy mode / paste tmux buffer |
| `prefix d` | Detach without stopping processes |
| `prefix ?` | List bindings |
| `tmux list-windows` | Find windows left running after closing VS Code terminals |
| `tmux kill-window -t <window>` | Close a leftover window |
| `prefix f` | lazy-tmux picker: switch live sessions or restore a saved session |
| `prefix Ctrl-s` | Save all sessions with lazy-tmux |

Mouse selection, pane resizing, and scrolling are enabled. System clipboard
integration depends on the terminal.

## Sessions

```sh
tmux new-session -s project       # create outside tmux
tmux new-window -n editor         # create inside tmux
tmux list-sessions
tmux switch-client -t project     # switch inside tmux
tmux attach-session -t project     # attach outside tmux

lazy-tmux save --all
lazy-tmux list
lazy-tmux picker
lazy-tmux sleep --session project
lazy-tmux wakeup --session project

ltm save --all
ltm list
ltm picker
ltm sleep --session project
ltm wakeup --session project
```

Saving is manual. Optional periodic snapshots: `lazy-tmux daemon --interval 3m`
(`Ctrl-c` stops it). Add `--scrollback` to save terminal output. Snapshots live
under `~/.local/share/lazy-tmux`; restoring reruns commands and does not restore
live processes or unsaved editor buffers. Restore only trusted snapshots.

Configuration is managed by Nix; do not run
`lazy-tmux setup >> ~/.tmux.conf`. Reload after switching Home Manager:

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

The lazy-tmux package is defined in [package.nix](./package.nix), and Fish
completions are in [completions/](./completions/). Theme configuration:
[theme.nix](./theme.nix).
