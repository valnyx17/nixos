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

    # Docker stacks
    ## Bootstrap
    ./stacks/core/traefik/docker-compose.nix
    ./stacks/core/caddy/docker-compose.nix
    ## Internal
    ./stacks/private/portainer.internal.solvia.dev/docker-compose.nix
    ./stacks/private/passbolt.internal.solvia.dev/docker-compose.nix
    ./stacks/private/pterodactyl.internal.solvia.dev/docker-compose.nix
    ./stacks/private/immich.internal.solvia.dev/docker-compose.nix
    ## Public
    ./stacks/public/solvia.dev/docker-compose.nix
    ./stacks/public/git.solvia.dev/docker-compose.nix
    ./stacks/public/matrix.solvia.dev/docker-compose.nix
  ];

  users.mutableUsers = false;

  users.motd = ''
    Welcome to the Storyboard   !
  '';

  users.users.v = {
    uid = 1000;
    description = "SD. V";
    hashedPasswordFile = config.sops.secrets.v-password.path;
    isNormalUser = true;
    home = "/home/v";
    createHome = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../files/id_user.pub)
    ];

    extraGroups = [
      "wheel"
      "networkmanager"
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

  networking.hostName = "storyboard";
  networking.networkmanager.enable = true;

  # Services
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;

    storageDriver = "btrfs";
  };

  virtualisation.oci-containers.backend = "docker";

  # VPN setup
  networking.wireguard.interfaces = {
    # Reverse Proxy
    wg0 = {
      ips = ["10.10.0.3/32"];
      privateKeyFile = config.sops.secrets.reverse_proxy_client_privkey.path;
      table = "69";

      postSetup = "ip rule add from 10.10.0.3 table 69";
      preShutdown = "ip rule del from 10.10.0.3 table 69";

      peers = [
        {
          publicKey = "xyfAr0txpaWh7i2D0KOjt/T7qTUlkgLEbvc+gUsH3zY=";
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = "solvia.dev:55107";
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Tailscale fixer-uppers
  networking.nat = {
    enable = true;
    enableIPv6 = true;

    internalInterfaces = ["ens18"];
    externalInterface = "wg0";
  };

  # Volumes
  fileSystems."/mnt/NASBox" = {
    device = "192.168.1.4:/mnt/storage/Something";
    fsType = "nfs";
  };

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs) htop btop micro nano;
  };

  networking.firewall.enable = true;

  networking.firewall.interfaces."ens18".allowedTCPPorts = [80 443];
  networking.firewall.interfaces."wg0".allowedTCPPorts = [8000];

  system.stateVersion = "25.05";
}
