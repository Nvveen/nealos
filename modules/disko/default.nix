{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.nealos.disk;

  luksName = "nealos";

  rootDevice =
    if cfg.encrypt then "/dev/mapper/${luksName}" else "/dev/disk/by-partlabel/disk-main-root";

  opts = [
    "compress=zstd:1"
    "noatime"
    "discard=async"
  ];

  # CoW is pathological for VM images and databases; only settable on an empty subvolume.
  cowFree = [
    "nodatacow"
    "noatime"
  ];

  # btrbk addresses subvolumes by path, which only exist under the btrfs top level.
  topLevel = "/btrfs";

  btrfs = {
    type = "btrfs";
    extraArgs = [
      "-L"
      "nealos"
      "-f"
    ];
    # Nested subvolumes are skipped by btrfs snapshots, so this layout doubles as
    # the snapshot exclusion list.
    subvolumes = {
      "@root" = {
        mountpoint = "/";
        mountOptions = opts;
      };
      "@nix" = {
        mountpoint = "/nix";
        mountOptions = opts;
      };
      "@home" = {
        mountpoint = "/home";
        mountOptions = opts;
      };
      # Reserved for a future impermanent root; unused today.
      "@persist" = {
        mountpoint = "/persist";
        mountOptions = opts;
      };
      "@log" = {
        mountpoint = "/var/log";
        mountOptions = opts;
      };
      "@snapshots" = { };
      "@libvirt" = {
        mountpoint = "/var/lib/libvirt";
        mountOptions = cowFree;
      };
      "@containers" = {
        mountpoint = "/var/lib/containers";
        mountOptions = cowFree;
      };
    }
    // lib.optionalAttrs cfg.hibernate {
      "@swap" = {
        mountpoint = "/swap";
        mountOptions = cowFree;
        # disko creates the swapfile with `btrfs filesystem mkswapfile` and emits the
        # corresponding swapDevices entry for /swap/swapfile.
        swap.swapfile.size = cfg.swapSize;
      };
    };
  };
in
{
  imports = [
    inputs.disko.nixosModules.disko
  ];
  options.nealos.disk = {
    device = lib.mkOption {
      type = lib.types.str;
      description = "Whole-disk device to partition. Use /dev/disk/by-id/... on bare metal.";
    };

    encrypt = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Put everything but the ESP in a LUKS container, unlocked by passphrase at boot.";
    };

    hibernate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Create a btrfs swapfile sized for hibernation.";
    };

    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "16G";
      description = "Size of the hibernation swapfile.";
      # Effective at format time only: disko creates the swapfile once; resizing later
      # means deleting /swap/swapfile and recreating it by hand, not a rebuild.
    };

    tpm = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Unlock the LUKS container with the TPM at boot; requires encrypt.";
    };

    espSize = lib.mkOption {
      type = lib.types.str;
      default = "1G";
      description = "Size of the EFI System Partition. Format-time only. Use 2G or more for Secure Boot hosts, where each generation is a full UKI.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path on the *installer* to a file holding the LUKS passphrase. null means disko prompts interactively. Only read during initial formatting.";
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg.tpm -> cfg.encrypt;
        message = "nealos.disk.tpm requires nealos.disk.encrypt: TPM unlock only applies to a LUKS container.";
      }
      {
        assertion = cfg.tpm -> config.boot.initrd.systemd.enable;
        message = "nealos.disk.tpm requires boot.initrd.systemd.enable: crypttabExtraOpts is ignored by the scripted initrd.";
      }
      {
        assertion = cfg.passwordFile != null -> cfg.encrypt;
        message = "nealos.disk.passwordFile requires nealos.disk.encrypt: there is no LUKS container to unlock.";
      }
    ];

    disko.devices.disk.main = {
      type = "disk";
      inherit (cfg) device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = cfg.espSize;
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            priority = 2;
            size = "100%";
            content =
              if cfg.encrypt then
                {
                  type = "luks";
                  name = luksName;
                  settings.allowDiscards = true;
                  content = btrfs;
                }
                // lib.optionalAttrs (cfg.passwordFile != null) {
                  inherit (cfg) passwordFile;
                }
              else
                btrfs;
          };
        };
      };
    };

    fileSystems = {
      "/var/log".neededForBoot = true;

      ${topLevel} = {
        device = rootDevice;
        fsType = "btrfs";
        options = [
          "subvolid=5"
          "noatime"
        ];
      };
    };

    boot.supportedFilesystems.btrfs = true;

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };

    # Discard is handled by the discard=async mount option; periodic fstrim is redundant.

    zramSwap.enable = true;

    # Hibernation additionally needs boot.kernelParams = [ "resume_offset=<N>" ], where N
    # comes from `btrfs inspect-internal map-swapfile -r /swap/swapfile` after install.
    # Without it, hibernation silently fails to resume.
    boot.resumeDevice = lib.mkIf cfg.hibernate rootDevice;

    # Not sufficient on its own: enroll the TPM keyslot once per machine after install with
    # `systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7 <luks-partition>`.
    # The passphrase keyslot remains as fallback.
    # mkIf must sit on the devices set, not the leaf: a leaf-level mkIf still instantiates
    # the ${luksName} submodule, which lacks a `device` when encrypt = false.
    boot.initrd.luks.devices = lib.mkIf cfg.tpm {
      ${luksName}.crypttabExtraOpts = [
        "tpm2-device=auto"
        "tpm2-measure-pcr=yes"
      ];
    };

    # Only /home is snapshotted: the rest is rebuilt from the flake, and rolling
    # back to an older generation is the bootloader's job.
    services.btrbk.instances.local = {
      onCalendar = "hourly";
      settings = {
        snapshot_preserve_min = "2d";
        snapshot_preserve = "48h 14d 8w 6m";
        timestamp_format = "long";
        volume.${topLevel} = {
          snapshot_dir = "@snapshots";
          subvolume."@home" = { };
        };
      };
    };
  };
}
