# Provisioning a new host

Runbook. Background on the keys involved is in [SECRETS.md](./SECRETS.md).

Four phases: prepare on an existing machine, gather hardware facts from the target,
install, then enrol the new host.

Phase 2 exists because two things can only be known once the machine is booted — its
disk's stable device path and its kernel module set. It costs one round trip and
removes all the guessing.

---

## Phase 1 — Prepare (on an existing machine)

A host decrypts secrets using its SSH host key, but that key is normally generated on
first boot — so a new machine can't decrypt anything on its first build. Fix: generate
the host key yourself, in advance.

**1. Generate the host key**

```bash
mkdir -p seed/etc/ssh
ssh-keygen -t ed25519 -N "" -C root@desktop -f seed/etc/ssh/ssh_host_ed25519_key
chmod 600 seed/etc/ssh/ssh_host_ed25519_key
```

If you have the private key but not the public half:

```bash
ssh-keygen -y -f seed/etc/ssh/ssh_host_ed25519_key > seed/etc/ssh/ssh_host_ed25519_key.pub
chmod 644 seed/etc/ssh/ssh_host_ed25519_key.pub
```

**2. Derive its age recipient**

```bash
ssh-to-age -i seed/etc/ssh/ssh_host_ed25519_key.pub
# age1xyz...
```

**3. Add it to `.sops.yaml`** under `keys:` and in the `key_groups.age` list.

**4. Re-encrypt to the new recipient list**

```bash
sops updatekeys secrets/common.yaml
```

Values are untouched — only the wrapped data key changes.

**5. Create `hosts/<host>/` and wire it into `flake.nix`.**

At minimum the host needs:

- `nealos.disk.device` — filled in during Phase 2, so leave it out for now.
- `nealos.disk.encrypt` / `.tpm` / `.hibernate` — decide these before installing; all
  three are baked into the on-disk layout and changing them later means a reformat.
- `hardware-configuration.nix` — generated in Phase 2.

Don't copy hyperv's hardware config as a starting point. Its kernel modules are the
Hyper-V virtio set and are wrong on bare metal.

**6. Commit and push**

```bash
echo "seed/" >> .gitignore     # holds a real private key
git add .sops.yaml secrets/ hosts/<host> && git commit && git push
```

The new host can now decrypt, despite not existing yet. It will also accept SSH from
your existing machines the moment it boots — the repo it builds from already contains
their pubkeys.

---

## Phase 2 — Gather hardware facts (on the target, from the ISO)

Boot the target from the installer ISO and clone the repo.

**1. Find the disk's stable path**

```bash
ls -l /dev/disk/by-id/
```

Pick the `nvme-…` or `ata-…` entry that is *not* a `-part<N>` symlink. Never use
`/dev/sda` or `/dev/nvme0n1` on a multi-drive machine — enumeration order isn't
guaranteed, and `--mode destroy,format,mount` is not undoable.

Put it in `hosts/<host>/`:

```nix
# hosts/<host>/default.nix
nealos.disk.device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_1TB_S6...";
```

The install path is a choice, not a phase split: the only thing that changes is how the
system is installed. The automatic local and remote paths do not need a pre-seed step
in the prose; they can inject the SSH host key as part of the install. The manual path
is where the key is explicitly created in the target root before the first activation.

**1. Generate the hardware config from the installer when the host is created**

For every install path — automatic local, automatic remote, or manual — generate the
hardware config from the installer as soon as the new host is installed, then commit the
result to the repo as part of creating that host definition:

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

This is not a later cleanup step; it belongs to the host-creation flow. `--no-filesystems`
is not optional. Disko owns every `fileSystems` entry; letting `nixos-generate-config`
also emit them gives you a conflict, or worse a silently wrong `fsType`. What's left is
the part that's genuinely per-machine: `boot.initrd.availableKernelModules`,
`hardware.cpu.*.updateMicrocode`, and similar.

Copy `/mnt/etc/nixos/hardware-configuration.nix` into `hosts/<host>/` and commit it with
that host's initial config. If `nixos-hardware` has a profile for this machine — likely
for a laptop, unlikely for a self-built desktop — import it too.

---

## Phase 3 — Install the host

Choose exactly one install path below.

### Automatic local (`disko-install`)

This is the shortest route when the hardware is already booted in the installer and the
host flake is ready. It formats/mounts the disk and installs the system in one step.

```bash
lsblk
sudo nix run github:nix-community/disko/latest#disko-install -- \
  --flake .#<host> \
  --disk <disk-name> /dev/disk/by-id/<target-disk> \
  --extra-files ./seed/etc/ssh /etc/ssh
```

Use `lsblk` to confirm the disk name you want to target before the install starts. The
`--extra-files` flag copies the pre-generated SSH host key into `/etc/ssh` before the
first activation, so the system can decrypt secrets as soon as it boots.

### Automatic remote (`nixos-anywhere`)

This is the remote equivalent for installing onto a machine that is reachable over SSH.
It is useful when the target is already booted into an installer, but you want to drive
it from another machine.

```bash
sudo nix run github:nix-community/nixos-anywhere -- \
  --flake .#<host> \
  --target-host root@<target-host> \
  --extra-files ./seed
```

`--extra-files ./seed` copies the seed tree to the root of the new installation; for this
repo that means the generated SSH host key lands under `/etc/ssh/` before activation.
If the target needs a custom SSH port or key path, pass those through with the matching
`nixos-anywhere` flags.

### Manual (`disko` + `nixos-install`)

Use this when you want the exact steps visible and controlled. This is the path where
the host key is actually preseeded into the new root before the first activation.

**1. Prepare the disk with disko**

```bash
sudo nix run github:nix-community/disko -- \
  --mode destroy,format,mount --flake .#<host>
```

Destructive, no confirmation. With `encrypt = true` this prompts for the LUKS
passphrase — you set it here, and it's the fallback even after TPM enrolment. Check
`lsblk -f` afterwards; everything should be under `/mnt`.

**2. Seed the host key into the new root**

```bash
sudo install -d -m 0755 /mnt/etc/ssh
sudo install -m 0600 ~/nealos/seed/etc/ssh/ssh_host_ed25519_key     /mnt/etc/ssh/
sudo install -m 0644 ~/nealos/seed/etc/ssh/ssh_host_ed25519_key.pub /mnt/etc/ssh/
```

This has to happen after the filesystem exists, but before the first build that tries
to decrypt secrets. The system is not there yet during the earlier phases, so this is a
manual install concern, not a general pre-install step.

**3. Install the system**

```bash
cd ~/nealos
sudo mkdir -p /mnt/tmp
sudo TMPDIR=/mnt/tmp nixos-install --flake .#<host> --no-root-password
```

`TMPDIR` keeps build scratch on disk instead of the ISO's RAM tmpfs — without it you
hit ENOSPC on a graphical closure. `--no-root-password` just skips the interactive
prompt; only safe because a user with a sops-delivered hash and `wheel` is declared.

Then `reboot`.

---

## Phase 4 — Enrol (after first boot)

Confirm secrets arrived before anything else:

```bash
systemctl status sops-nix
```

If the password hash failed to decrypt you'll find out at the login prompt — recover
via the ISO and `nixos-enter`.

**1. Enrol the TPM keyslot** (if `nealos.disk.tpm` is set). Not declarative — the
keyslot lives in the LUKS header on disk, so it's once per machine:

```bash
systemd-analyze has-tpm2
sudo systemd-cryptenroll --tpm2-device=auto \
  --tpm2-pcrs=0+2+7 /dev/disk/by-id/<disk>-part2
```

Prompts for the passphrase you set in Phase 2, then seals a key to those PCRs. Reboot
to verify it unlocks without prompting. A firmware update or Secure Boot change alters
the PCRs and drops you back to the passphrase — annoying, not a lockout, so long as you
remember it.

**2. Enrol the Tang keyslot** (for hosts using LAN unlock). This is also not
declarative: Clevis writes a binding token into the LUKS header. The NixOS config can
be built before the Tang server is online, but binding needs the server to be reachable.

Generate Tang server keys on the Tang server, not on the NixOS client. If the server is
managed by a distro package, start the service first; many packaged units create missing
keys on first start. For a manual setup:

```bash
sudo mkdir -p /var/db/tang
sudo tangd-keygen /var/db/tang
```

Then confirm the server advertises its keys from the client LAN:

```bash
curl http://192.168.68.53:7500/adv
```

Once the advertisement works, bind the LUKS root device from `nealdesk`:

```bash
sudo clevis luks bind \
  -d /dev/disk/by-id/nvme-eui.002538db11c3bf88-part2 \
  tang '{"url":"http://192.168.68.53:7500"}'
```

Inspect or remove bindings with:

```bash
sudo clevis luks list -d /dev/disk/by-id/nvme-eui.002538db11c3bf88-part2
sudo clevis luks unbind -d /dev/disk/by-id/nvme-eui.002538db11c3bf88-part2 -s <slot>
```

Reboot with Ethernet attached to verify network unlock. If the LAN, Tang server, or
initrd networking is unavailable, the passphrase remains the recovery path.

**3. Generate the user key:**

```bash
ssh-keygen -t ed25519 -C "neal@$(hostname)" -f ~/.ssh/id_ed25519 -N ""
```

**4. Register it with GitHub** — run this from an **existing, already-authenticated
host**, not the new one:

```bash
ssh newhost cat ~/.ssh/id_ed25519.pub | gh ssh-key add - --title newhost
```

Only `cat` runs remotely; the pubkey is piped into the old host's `gh`. Nothing
gh-related executes on the new machine, and no account-level credential ever lands on
it. If gh lacks the scope: `gh auth refresh -h github.com -s admin:public_key`.

For the *first* machine in a fresh fleet there's no existing host — do a one-off
`gh auth login` locally, or paste the pubkey into the GitHub web UI.

**5. Commit the pubkey** — the new host can push now, so it can do this itself:

```bash
cp ~/.ssh/id_ed25519.pub ~/nealos/users/neal/keys/$(hostname).pub
cd ~/nealos && git add users/neal/keys && git commit -m "Add $(hostname) user key" && git push
```

**6. Rebuild the other hosts** so they accept SSH from the new machine. Nothing
happens on a `git pull` alone.

**7. If hibernation is enabled**, get the swapfile offset and add it to
`boot.kernelParams`:

```bash
sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
```

Hibernation silently fails to resume without `resume_offset=<N>`.

**Verify:**

```bash
ssh -T git@github.com     # from the new host
ssh oldhost               # from the new host, after step 5
```

---

## Building the installer ISO

```bash
nix build .#iso
```

Then `dd` the result. Note that `nix.settings.substituters` in the flake configures the
*installed* system, not the live environment — to pass substituters to a running ISO's
nix, use `NIX_REMOTE=` plus inline `--option` flags, or `NIX_CONFIG`.
