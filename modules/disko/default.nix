{ config, lib, ... }:

let
  cfg = config.nealos.disk;

  luksName = "nealos";

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
    };
  };
in
{
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
  };

  config = {
    disko.devices.disk.main = {
      type = "disk";
      inherit (cfg) device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
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
              else
                btrfs;
          };
        };
      };
    };

    fileSystems = {
      "/var/log".neededForBoot = true;

      ${topLevel} = {
        device =
          if cfg.encrypt then "/dev/mapper/${luksName}" else "/dev/disk/by-partlabel/disk-main-root";
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

    services.fstrim.enable = true;

    zramSwap.enable = true;

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
