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
    ../../system/battery.nix
    ../../system/security.nix
    ../../system/virtualisation.nix
    # ../../system/kanata.nix
    ../../system/sshd.nix
    ../../system/pipewire.nix
    ../../system/lnr.nix
    ../../system/fonts.nix
    ../../system/console.nix
    ../../system/gui.nix
    ../../system/i18n.nix
    ../../system/nix-ld.nix
  ];

  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  # just in case for thunderbolt
  services.hardware.bolt.enable = true;

  sops.secrets.v-password.neededForUsers = true;
  sops.secrets.root-password.neededForUsers = true;
  users.mutableUsers = false;

  users.users.v = {
    uid = 1000;
    description = "SD. V";
    hashedPasswordFile = config.sops.secrets.v-password.path;
    home = "/home/v";
    createHome = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../files/id_user.pub)
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
    hashedPasswordFile = config.sops.secrets.root-password.path;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ../../files/id_user.pub)
    ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "wireframe";
  networking.networkmanager.enable = true;
  boot.supportedFilesystems = ["ntfs"];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # services (in general)
  services.gvfs.enable = true;
  services.libinput.enable = true;
  services.printing.enable = true;
  services.flatpak.enable = true;

  programs.adb.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  programs.appimage.binfmt = true;

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs.unstable) unzip zip libvterm-neovim steam;
  };

  # fingerprint support
  services.fprintd.enable = true;
  system.stateVersion = "24.11";
}
