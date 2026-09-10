# Secrets

How secrets and keys work in this repo. For the step-by-step of bringing up a new
machine, see [PROVISIONING.md](./PROVISIONING.md).

## Model

Three keys, and keeping them straight is the whole thing:

| Key | What it is | Where it lives |
|---|---|---|
| **Admin age key** | Decrypts every secret file. Used by *you* to edit secrets. | `~/.config/sops/age/keys.txt`, backed up in Bitwarden |
| **Host key** | `/etc/ssh/ssh_host_ed25519_key`, converted to an age identity by sops-nix. Decrypts secrets at activation. | On each machine, pre-seeded at install |
| **User key** | `~/.ssh/id_ed25519` for `neal`. Per-machine identity for GitHub and inter-host SSH. | Generated on the machine, never leaves it |

Only the first two are secrets in the sops sense. The user key's *private* half never
moves anywhere — only its public half gets committed and registered.

Secrets are encrypted in git and safe to push publicly. At activation a systemd unit
decrypts them into `/run/secrets/` (tmpfs) with declared owner and mode. Nix files only
ever reference **paths**, never values — nothing plaintext touches `/nix/store`.

## Layout

```
.sops.yaml                    # recipient list + creation rules
secrets/common.yaml           # encrypted secrets (committed)
seed/etc/ssh/                 # host keys for machines not yet installed — GITIGNORED
modules/common/
  authorized-keys.nix         # scans the dirs below
users/
  neal/
    keys/
      desktop.pub             # public keys, plaintext, committed
      laptop.pub
      hyperv.pub
```

```yaml
# .sops.yaml
keys:
  - &admin   age1abc...
  - &hyperv  age1def...
  - &desktop age1xyz...
creation_rules:
  - path_regex: secrets/[^/]+\.yaml$
    key_groups:
      - age: [*admin, *hyperv, *desktop]
```

## Editing secrets

```bash
sops secrets/common.yaml
```

Requires the admin key at `~/.config/sops/age/keys.txt`. If sops errors listing age
recipients it can't decrypt with, that file is missing — restore it from Bitwarden.

Keys nest with `/`-separated paths, so `neal/password` in Nix maps to:

```yaml
# secrets/common.yaml — decrypted view
neal:
  password: $y$j9T$...
```

## Declaring a secret

```nix
# modules/secrets/default.nix
sops.secrets."some/secret" = {
  owner = "neal";
  mode  = "0400";
};
```

Defaults are `root` / `0400`, which means *your* processes can't read it — set `owner`
explicitly for anything user-facing. Reference the path dynamically rather than
hardcoding it: `config.sops.secrets."some/secret".path`.

### Password hashes

```bash
mkpasswd -m yescrypt
```

Put the hash in `secrets/common.yaml`, then:

```nix
# users/neal/nixos.nix
sops.secrets."neal/password".neededForUsers = true;
users.users.neal.hashedPasswordFile = config.sops.secrets."neal/password".path;
```

`neededForUsers = true` decrypts earlier in activation and places the file under
**`/run/secrets-for-users/`**, not `/run/secrets/`. Use the `.path` attribute and it
resolves either way.

## User SSH keys

Each machine has its own keypair per user. Public halves are committed as plain files under
`users/<user>/keys/` and picked up by directory scan in `modules/common/authorized-keys.nix` —
adding a machine means dropping a `.pub` in and rebuilding, with no `.nix` file
touched. `keyFiles` merges with `keys`, so a literal string can still be added for
anything that shouldn't live in the tree (CI deploy key, resident Yubikey key).

Why per-host rather than one shared key in sops: revoking a lost laptop is one click in
GitHub settings, instead of rotating a key that three machines share.

**No GitHub token lives on any machine.** Registering a key is deliberately a manual
step run from an already-authenticated host. Putting a PAT in sops would automate it,
but would give every host the ability to mint new account access — strictly worse than
the shared key this setup replaced.

## Gotchas

- **Flakes only see committed files.** `git add .` before every rebuild or install. An
  untracked `.pub` is invisible to `readDir` and disappears silently rather than
  erroring; likewise an untracked `keys/` makes `pathExists` return false.
- **`keyFiles` is baked into the built system.** After adding a pubkey, every other host
  needs `nixos-rebuild switch` before it will accept the new machine. A `git pull` alone
  does nothing.
- **`seed/` is gitignored** — it holds real private keys. Keep it on an encrypted USB
  stick if you might re-image and want the same identity back, otherwise `shred -u`.
- **Losing the admin key locks you out of editing** (not out of the machines — those
  decrypt with their own host keys). Bitwarden is the backup.
- **Reinstalling while preserving `/etc/ssh` keeps the host's identity**, so no
  `sops updatekeys` is needed — but your admin `keys.txt` is a home-directory file and
  does *not* survive; restore it separately. The user key doesn't survive either:
  regenerate and re-enroll, or back it up alongside `seed/`.