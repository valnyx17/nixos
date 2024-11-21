{
  config,
  lib,
  pkgs,
  outputs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  # users
  users.users.valerie = {
    uid = 1337;
    initialPassword = "giggle,iamsonaughty.";
    home = "/home/valerie";
    createHome = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_user.pub)
    ];
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "docker"
      "input"
      "libvirtd"
      "plugdev"
      "video"
      "adbusers"
      "uinput"
    ];
  };

  users.users.root = {
    shell = pkgs.zsh;
    extraGroups = [];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_user.pub)
    ];
  };

  system.stateVersion = "24.05";

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };
  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];

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

  # system-wide pkgs
  environment.systemPackages = with pkgs;
    [
      python3
      fuse3
      floorp
      localsend
      parsec-bin
      kanata
      bubblewrap
      inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
    ]
    ++ [
      (unstable.koboldcpp.override {
        cublasSupport = true;
        cudaArches = ["sm_86"];
      })
    ];

  # security
  security = {
    # don't ask password for wheel group, disk is encrypted with a secure password & ssh auth with password is disabled!
    sudo.wheelNeedsPassword = false;
    # enable trusted platform module 2 support
    tpm2.enable = true;
  };

  # boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "waves";
  networking.networkmanager.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  # virtualisation
  virtualisation.containers.cdi.dynamic.nvidia.enable = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
  virtualisation.vmware.host.enable = true;
  virtualisation.docker.enable = true;

  # kanata
  boot.kernelModules = ["uinput"];
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"
  '';

  # ssh
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      UseDns = true;
      X11Forwarding = false;
    };
  };

  # sound
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
  hardware.pulseaudio.enable = false;

  # services (in general)
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.libinput.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;

  # local name resolution
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns = true;
  };
  system.nssModules = pkgs.lib.optional true pkgs.nssmdns;
  system.nssDatabases.hosts = pkgs.lib.optionals true (pkgs.lib.mkMerge [
    (pkgs.lib.mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolution
    (pkgs.lib.mkAfter ["mdns4"]) # after dns
  ]);

  # syncthing
  services.syncthing = {
    enable = true;
    user = "valerie";
    dataDir = "/home/valerie";
    configDir = "/home/valerie/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "truenas" = {
          id = "2HEHVRP-6Z4FBIB-MULQ6Y2-XP2IW6Q-WVOVKOR-HSJBZ3O-RUN7DZI-SAM2SAA";
          autoAcceptFolders = true;
        };
      };
      folders = {
        "Explicit Sync" = {
          path = "/home/valerie/sync";
          devices = ["truenas"];
        };
        "zettelkasten" = {
          path = "/home/valerie/zet";
          devices = ["truenas"];
        };
      };
    };
  };

  # adb
  programs.adb.enable = true;

  # console
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # fonts
  fonts = {
    enableDefaultPackages = false;
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["0xProto" "Intel One Mono" "Symbols Nerd Font" "Noto Color Emoji"];
        serif = ["Alegreya" "Petrona" "Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Atkinson Hyperlegible" "Overpass" "Nunito" "Noto Color Emoji"];
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
      pkgs.intel-one-mono
      pkgs._0xproto

      pkgs.material-design-icons
      (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito" "Alegreya" "Petrona" "Atkinson Hyperlegible"];})
      (pkgs.unstable.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
  };

  # nvidia
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
  boot.kernelParams = ["nvidia-drm.fbdev=1" "sysrq_always_enabled=1"];

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

  # gui
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      # for packages that are pkgs.*
      gnome-tour
      gnome-connections
    ])
    ++ (with pkgs.gnome; [
      # for packages that are pkgs.gnome.*
      epiphany # web browser
      geary # email reader
      evince # document viewer
    ]);
  services.displayManager.cosmic-greeter.enable = false;
  services.desktopManager.cosmic.enable = true;

  # i18n
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

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
  environment.pathsToLink = ["/share/zsh"];

  # Enable nix ld
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    readline
    cairo
    cups
    curl
    dbus
    expat
    fontconfig
    freetype
    fuse3
    gdk-pixbuf
    glib
    gtk3
    icu
    libGL
    libappindicator-gtk3
    libdrm
    libglvnd
    libnotify
    libpulseaudio
    libunwind
    libusb1
    libuuid
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    pango
    pipewire
    stdenv.cc.cc
    stdenv.cc.cc.lib
    systemd
    vulkan-loader
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    xorg.libxkbfile
    xorg.libxshmfence
    fzf
    zlib
    libgit2
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
}
