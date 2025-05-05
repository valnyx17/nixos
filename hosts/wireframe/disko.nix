# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./disko.nix --argstr device "/dev/..."
# nixos-generate-config --no-filesystems --root /mnt
# -- move nixos folder to /mnt/etc/nixos
# nixos-install --flake /mnt/etc/nixos#wireframe --root /mnt
#
# https://github.com/nix-community/disko/blob/master/docs/quickstart.md
#
# make sure to put this nixos configuration into /etc/nixos after successful install. Also, add the generated sops key into the .sops.yaml and rebuild for sops support (do not forget `sops updatekeys -y secrets/secrets.yaml`)
#
# REMOVE: https://www.youtube.com/watch?v=nLwbNhSxLd4 (Full NixOS Guide)
# REMOVE: https://www.youtube.com/watch?v=YPKwkWtK7l0
# IMPORTANT: this disk configuration is setup for *impermanance* systems.
#            to get rid of impermanance support, simply remove the "/persist" btrfs subvolume.
# to import, add this to the imports list:
# (import ./disko.nix { device = "/dev/?" })
{device ? throw "Set this to your disk device, e.g. /dev/disk/by-id/...", ...}: {
  disko.devices = {
    disk = {
      main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # boot = {
            #   name = "boot";
            #   size = "1M";
            #   type = "EF02";
            # };
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/secret.key";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "root_vg";
                };
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
                  # mountOptions = ["compress=zstd" "noatime"];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  # mountOptions = ["compress=zstd" "subvol=persist" "noatime"];
                  mountOptions = ["subvol=persist" "noatime"];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "subvol=home" "noatime"];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "subvol=nix" "noatime"];
                };
              };
            };
          };
        };
      };
    };
  };
}
