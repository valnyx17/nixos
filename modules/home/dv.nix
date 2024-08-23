{pkgs, lib, config, inputs, outputs, ...}: {
    imports = [
        ./services.nix
        ./programs.nix
        # development
        ./dev
        # terminal
        ./term
        # gui
        ./gui-core.nix
        ./ags.nix
        ./niri.nix
    ];

	nix = {
	  #package = pkgs.nix;
	  registry.nixpkgs.flake = inputs.nixpkgs;
	  gc.automatic = true;
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      #allowUnfree = true;
    };
	};

	nixpkgs.config = {
		allowUnfree = true;
		cudaSupport = true;
	};
	nixpkgs.overlays = [
	  outputs.overlays.additions
	  outputs.overlays.modifications
	  outputs.overlays.unstable-packages
            inputs.niri.overlays.niri
	];
    home = {
        file.".ssh/id_user.pub".text = builtins.readFile ../nixos/id_user.pub;
        username = "dv";
        homeDirectory = "/dv";
        extraOutputsToInstall = ["doc" "devdoc"];
        packages = [
            inputs.nh.packages.x86_64-linux.default
           pkgs.nom
           pkgs.pinta
           pkgs.vesktop
           pkgs.signal-desktop
           pkgs.blockbench
           pkgs.blender
           pkgs.prismlauncher
           pkgs.steam
        ];
        sessionVariables = {
            NIX_AUTO_RUN = "1";
            FLAKE = "/dv/nixos";
        };
        stateVersion = "24.11";
    };
        nix.package = lib.mkForce pkgs.unstable.nixVersions.latest;
        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';
        manual = {
          html.enable = false;
          json.enable = false;
          manpages.enable = false;
        };
        programs.home-manager.enable = true;
        programs.git.enable = true;
        #programs.nix-index.enable = true;
        #programs.nix-index.symlinkToCacheHome = true;
        #programs.nix-index-database.comma.enable = true;
        systemd.user.startServices = "sd-switch";
}
