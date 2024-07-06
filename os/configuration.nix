{
  config,
  lib,
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  nixpkgs.config = {allowUnfree = true;};
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];

  virtualisation.docker = {
    enable = true;
  };

  virtualisation.containers.cdi.dynamic.nvidia.enable = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;

  virtualisation.vmware.host.enable = true;

  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # security
  security = {
    sudo.wheelNeedsPassword = false; # don't ask password for wheel group, disk is encrypted with a secure password & ssh auth with password is disabled!
    # enable trusted platform module 2 support
    tpm2.enable = true;
  };

  environment.systemPackages = with pkgs; [
    neovim
    firefox
    #jmtpfs
  ];

  services.gvfs.enable = true;

  programs.adb.enable = true;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # allowUnfree = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      keep-derivations = true;
      keep-outputs = true;
      trusted-users = ["root" "@wheel"];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      UseDns = true;
      X11Forwarding = false;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.postDeviceCommands = lib.mkAfter (builtins.readFile ./btrfs-impermanence);

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  environment.pathsToLink = ["/share/zsh"];

  programs = {
    less.enable = true;

    # default zsh config if not configured using home-manager
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      promptInit = ''
        PS1='%B%1~%b %(#.#.$): '
      '';
    };
  };

  boot.supportedFilesystems = ["ntfs"];

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    lowLatency = {
      enable = true;
      # defaults (USES nix-gaming PIPEWIRE LOW LATENCY MODULE!)
      quantum = 64;
      rate = 48000;
    };
  };

  services.libinput.enable = true;
  services.printing.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";

  fonts = {
    enableDefaultPackages = false;
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Cascadia Code" "Symbols Nerd Font" "Noto Color Emoji"];
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Overpass" "Nunito" "Noto Color Emoji"];
      };
      hinting = {
        enable = true;
        autohint = false;
        style = "full";
      };
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
    packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-emoji

      pkgs.material-design-icons
      (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito"];})
      (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
  };

  #nvidia
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";

      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };
}
