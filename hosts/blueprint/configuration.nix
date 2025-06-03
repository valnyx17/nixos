{
  config,
  pkgs,
  lib,
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/nix.nix
    ../../system/sops.nix
    ../../system/impermanence.nix
    ../../system/sshd.nix
    ../../system/avahifixes.nix
    ../../system/i18n.nix
    ../../system/nh.nix

    ./caddy/docker-compose.nix
  ];

  users.mutableUsers = false;

  users.motd = ''
    Welcome to Blueprint!
  '';

  users.users.v = {
    uid = 1000;
    description = "SD. V";
    home = "/home/v";
    hashedPasswordFile = config.sops.secrets.v-password.path;
    isNormalUser = true;
    createHome = true;
    shell = pkgs.bash;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      git
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../files/id_user.pub)
    ];
  };

  users.users.tera = {
    uid = 1001;
    description = "Tera";
    home = "/home/tera";
    hashedPasswordFile = config.sops.secrets.tera-password.path;
    isNormalUser = true;
    createHome = true;
    shell = pkgs.bash;

    extraGroups = [
      "wheel"
      "networkmanager"
    ];

    packages = with pkgs; [
      git
    ];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../files/id_user_tera.pub)
    ];
  };

  security.sudo-rs.enable = true;

  networking.hostName = "blueprint";
  networking.networkmanager.enable = true;

  # Services
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    storageDriver = "btrfs";
  };

  virtualisation.oci-containers.backend = "docker";

  swapDevices = [
    {
      device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi-disk-1";
    }
  ];

  # VPN setup
  networking.wireguard.interfaces = {
    # Reverse Proxy
    wg0 = {
      listenPort = 55107;
      ips = ["10.10.0.1/24"];
      privateKeyFile = config.sops.secrets.reverse_proxy_server_privkey.path;

      peers = [
        {
          publicKey = "nzyTRgAUGWK9K9gFSUBRJZrBGC5N37pdlkhODkZ1nj4=";
          allowedIPs = ["10.10.0.3/32"];
        }
      ];
    };
  };

  # Tailscale fixer-uppers
  networking.nat = {
    enable = true;
    enableIPv6 = true;

    internalInterfaces = ["enp0s4"];
    externalInterface = "wg0";
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) htop btop micro nano;
  };

  # The VPS host has its own firewall. Might as well make it their job.
  networking.firewall.enable = false;
  system.stateVersion = "25.05";
}
