{
config,
lib,
pkgs,
outputs,
inputs,
...
}: let
  modulesPath = "./modules/nixos";
in  {
	imports = [
		./waves-hardware.nix
		inputs.nix-gaming.nixosModules.pipewireLowLatency
		"${modulesPath}/virtualisation.nix"
		"${modulesPath}/kanata.nix"
		"${modulesPath}/services.nix"
		"${modulesPath}/localnameresolution.nix"
		"${modulesPath}/syncthing.nix"
		"${modulesPath}/users.nix"
		"${modulesPath}/adb.nix"
		"${modulesPath}/console.nix"
		"${modulesPath}/fonts.nix"
		"${modulesPath}/nvidia.nix"
		"${modulesPath}/gui.nix"
		"${modulesPath}/i18n.nix"
		"${modulesPath}/zsh.nix"
	];

	#system.stateVersion = ""; #<- replace when have stateversion

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

	environment.systemPackages = with pkgs; [
		unstable.neovim
		fuse3
		floorp
		localsend
		parsec-bin
	];

# security
  security = {
    sudo.wheelNeedsPassword = false; # don't ask password for wheel group, disk is encrypted with a secure password & ssh auth with password is disabled!
    # enable trusted platform module 2 support
    tpm2.enable = true;
  };

   boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  networking.networkmanager.enable = true;
  boot.supportedFilesystems = ["ntfs"];
}
