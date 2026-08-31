# nealxos

NixOS configuration for all my machines, plus a portable dotfiles module that
works on any Linux with home-manager.

## Structure

    dotfiles/           Portable home-manager. No NixOS assumptions.
    modules/
      base/nixos/       Every host gets this. Headless-safe.
      desktop/
        nixos/          Compositor, display manager, fonts, portals, boot splash.
        home/           Per-user desktop config: shell UI, theming, GUI apps.
        themes/         Palette assets shared by desktop/nixos and desktop/home.
      profiles/
        <name>/nixos/   Opt-in package sets. Imported by hosts that want them.
        <name>/home/    Per-user half of the same profile.
    users/
      <name>/nixos.nix  Account, groups, authorized keys.
      <name>/home.nix   Identity (git name/email) + imports dotfiles.
    hosts/
      <name>/           Hardware, disk layout, and which modules this host gets.

## Where does a new file go?

Two questions, in order.

### 1. Which module system?

NixOS options (`services.*`, `boot.*`, `environment.systemPackages`,
`programs.*` at system level) go in a `nixos/` directory.

Home-manager options (`home.*`, `xdg.*`, `programs.*` at user level) go in a
`home/` directory or `dotfiles/`.

These are two different module systems with overlapping option names. A file's
directory tells you which one it is. If you're unsure, look at what the file
already uses -- `environment.systemPackages` and `home.packages` never coexist
in the same module.

### 2. Which scope?

- Needed on a headless server? -> `modules/base/nixos/`
- Needed by any graphical machine? -> `modules/desktop/`
- Optional, per-machine? -> `modules/profiles/<name>/`
- True of one machine only? -> `hosts/<name>/`
- True of one person only? -> `users/<name>/`
- Works on Ubuntu with just home-manager? -> `dotfiles/`

## The dotfiles constraint

`dotfiles/` is imported by two entry points: `homeConfigurations.<user>` for
non-NixOS machines, and the NixOS side via home-manager. For the first to work,
nothing in `dotfiles/` may:

- reference a NixOS option
- assume a package exists that it did not install itself
- depend on systemd user units, a Wayland compositor, or anything graphical

If a config needs any of those, it belongs in `modules/desktop/home/` or a
profile's `home/`, not here.

`dotfiles/` is not "Neal's dotfiles" -- it is this project's idea of a good
shell, and every user imports it. Personal identity (git name, email) lives in
`users/<name>/home.nix`.

## Profiles

A profile is a set of related packages and config that a host opts into. There
is no subscription mechanism: a host imports the profile's `nixos/` module
directly, and that module wires up its own `home/` half.

    # modules/profiles/development/nixos/default.nix
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.vscode ];
      home-manager.sharedModules = [ ../home ];
    }

    # hosts/gamingrig/default.nix
    imports = [
      ../../modules/base/nixos
      ../../modules/desktop/nixos
      ../../modules/profiles/gaming/nixos
    ];

This gives the profile to every user on that host. If a profile ever needs to
apply to one user and not another, that requires
`home-manager.users.<name>.imports` instead -- don't build that until there is a
real case for it.

## Theming

Colours come from one source: a palette JSON in the `community-palettes` flake
input. `modules/desktop/home/theming/` generates per-consumer files from it
(Hyprland lua, GTK, neovim). `modules/desktop/nixos/` does the same for SDDM and
Plymouth, which are system-level.

Adding a newly themed application means adding an output to the generator, not
hardcoding colours.

## Usage

Rebuild a host:

    sudo nixos-rebuild switch --flake .#<host>

Install dotfiles on a non-NixOS machine:

    nix run home-manager/master -- switch --flake github:<you>/nealxos#<user>

Update one input:

    nix flake update <input>

Bare `nix flake update` bumps every input, which usually means rebuilding far
more than intended.

## Conventions

- **Commit before rebuilding.** Nix reads the git index for a dirty tree.
  Untracked files are invisible to the build, and unstaged edits to tracked
  files can be too.
- **`nixos-rebuild dry-build` before a large change.** It lists what will be
  built versus fetched, which distinguishes "not cached upstream" from "my
  config changed the derivation".
- **`follows` on module inputs, not package inputs.** Inputs providing modules
  (home-manager, disko) should set `inputs.nixpkgs.follows = "nixpkgs"` so their
  modules match our nixpkgs. Inputs providing packages with a binary cache
  (noctalia, nix-cachyos-kernel) must not -- following changes every derivation
  hash, so nothing matches their cache and it compiles from source.
- **Read the upstream option reference before theorising.** Most of the time
  lost building this was spent guessing at option names and semantics that were
  documented.