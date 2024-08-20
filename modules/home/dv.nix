{pkgs, lib, config, inputs, ...}: {
    imports = [
        ./services.nix
        ./programs.nix
        # development
        ./dev
        # terminal
        ./term
        # gui
        ./gui.nix
    ];

    home = {
        file.".ssh/id_user.pub".text = builtins.readFile ../nixos/id_user.pub;
        username = config.users.users.dv.name;
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
        # stateVersion = ""; <- figure out when installing WARNING:
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
        programs.nix-index.enable = true;
        programs.nix-index.symlinkToCacheHome = true;
        programs.nix-index-database.comma.enable = true;
        systemd.user.startServices = "sd-switch";
}
