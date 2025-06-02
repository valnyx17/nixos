{device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/...", ...}: {
  disko.devices = {
    disk = {
      main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            rootfs = {
              size = "100%";
              name = "NixOS";
              content = {
                type = "lvm_pv";
                vg = "root_vg";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      root_vg = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = ["subvol=persist" "noatime"];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["subvol=home" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["subvol=nix" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
}
