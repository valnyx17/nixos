{
  pkgs,
  lib,
  outputs,
  inputs,
  config,
  ...
}: let
  userOpts = {
    name,
    config,
    ...
  }: {
    options = with lib; {
      allowUnfree = mkOption {
        type = with types; bool;
        default = true;
        description = "Whether or not to allow unfree packages for this user.";
      };
      username = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The username of the user, if undefined it uses the name of the attribute set.";
      };
      homeDirectory = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The home directory of the user.";
      };
      description = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The user's description. It is usually their full name.";
      };
      uid = mkOption {
        type = with types; nullOr int;
        default = null;
        description = "The user id of the user.";
      };
      initialPassword = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The initial password of the user.";
      };
      hashedPassword = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The hashed password of the user.";
      };
      initialHashedPassword = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The initial hashed password of the user.";
      };
      normalUser = mkOption {
        type = with types; bool;
        default = false;
        description = "Whether the user is a system user.";
      };
      desktopEnvironment = mkOption {
        type = with types; nullOr (enum ["gnome" "hyprland" "bspwm"]);
        default = null;
        description = "The desktop environment of the user.";
      };
      developer = mkOption {
        type = with types; bool;
        default = false;
        description = "Whether or not the user is a developer.";
      };
      sudoer = mkOption {
        type = with types; bool;
        default = false;
        description = "Whether or not the user has access to sudo.";
      };
      obs = mkOption {
        type = with types; bool;
        default = false;
        description = "Whether or not the user requires OBS.";
      };
      authorizedKeys = mkOption {
        type = with types; listOf str;
        default = [];
        description = "List of Authorized SSH Keys for the user.";
      };
      extraGroups = mkOption {
        type = with types; listOf str;
        default = [];
        description = "Extra groups to put the user in.";
      };
      packages = mkOption {
        type = with types; listOf package;
        default = [];
        description = "The user's packages.";
      };
      shell = mkOption {
        type = with types; enum ["bash" "zsh"];
        default = "zsh";
        description = "The user's shell.";
      };
    };
    config = with lib;
      mkMerge [
        {
          shell = mkDefault "zsh";
        }
      ];
  };
in {
  options = with lib; {
    user = mkOption {
      type = with types; attrsOf (submodule userOpts);
      default = {};
      example = {
        deva = {
          shell = "zsh";
          sudoer = true;
          developer = true;
          desktopEnvironment = "gnome";
          obs = true;
          name = "Deva Waves";
        };
        root = {
          shell = "zsh";
          authorizedKeys = [];
        };
      };
    };
  };

  config = let
    mkIfNoValue = lib.mkOverride 1500;
  in {
    users.users = lib.mkIf (config.user != null) (lib.attrsets.mapAttrs (name: userConfig: {
        uid = (
          if userConfig.uid != null
          then userConfig.uid
          else mkIfNoValue null
        );
        initialPassword = (
          if userConfig.initialPassword != null
          then userConfig.initialPassword
          else mkIfNoValue null
        );
        hashedPassword = (
          if userConfig.hashedPassword != null
          then userConfig.hashedPassword
          else mkIfNoValue null
        );
        initialHashedPassword = (
          if userConfig.initialHashedPassword != null
          then userConfig.initialHashedPassword
          else mkIfNoValue null
        );
        description = (
          if userConfig.description != null
          then userConfig.description
          else mkIfNoValue "${name}"
        );
        shell = pkgs.${userConfig.shell};
        openssh.authorizedKeys.keys = userConfig.authorizedKeys or [];
        isNormalUser =
          if userConfig.normalUser
          then true
          else mkIfNoValue false;
        name =
          if userConfig.username != null
          then userConfig.username
          else mkIfNoValue name;
        extraGroups =
          (
            if userConfig.extraGroups != null
            then userConfig.extraGroups
            else mkIfNoValue []
          )
          ++ (
            if userConfig.sudoer
            then ["wheel"]
            else []
          );
      })
      config.user);

    home-manager.users = lib.mkIf (config.user != null) (lib.attrsets.mapAttrs (name: userConfig: {
        imports =
          [
	  inputs.nix-index-db.hmModules.nix-index
	  ]
          ++ (
            if name != "root"
            then [
              ../services.nix
            ]
            else []
          )
          ++ (
            if userConfig.developer
            then [
              ../dev
            ]
            else []
          )
          ++ (
            if userConfig.shell == "zsh"
            then [
              ../shell/zsh.nix
            ]
            else []
          )
          ++ (
            if userConfig.shell == "bash"
            then [
              ../shell/bash.nix
            ]
            else []
          )
          ++ (
            if userConfig.obs
            then [
              {
                programs.obs-studio = {
                  enable = true;
                  plugins = with pkgs.obs-studio-plugins; [
                    wlrobs
                  ];
                };
              }
            ]
            else []
          )
          ++ (
            if userConfig.desktopEnvironment == "gnome"
            then [
              ../desktop/gnome.nix
            ]
            else []
          )
          ++ (
            if userConfig.desktopEnvironment == "hyprland"
            then [
              ../desktop/hyprland.nix
            ]
            else []
          )
          ++ (
            if userConfig.desktopEnvironment == "bspwm"
            then [
              ../desktop/bspwm.nix
            ]
            else []
          );

        home = {
          username =
            if userConfig.username != null
            then userConfig.username
            else mkIfNoValue name;
          homeDirectory =
            if userConfig.homeDirectory != null
            then userConfig.homeDirectory
            else
              mkIfNoValue "/home/${(
                if userConfig.username != null
                then userConfig.username
                else name
              )}";
          extraOutputsToInstall = ["doc" "devdoc"];
          packages =
            [
              inputs.nh.packages.x86_64-linux.default
            ]
            ++ userConfig.packages or [];
          sessionVariables = {
            NIX_AUTO_RUN = "1";
            FLAKE = "${config.home-manager.users.${name}.home.homeDirectory}/nix";
          };
          stateVersion = "24.05";
        };

        nixpkgs =
          if config.home-manager.useGlobalPkgs != true
          then {
            overlays = [
              outputs.overlays.additions
              outputs.overlays.modifications
              outputs.overlays.unstable-packages
            ];
            config = {
              allowUnfree =
                if userConfig.allowUnfree != true
                then false
                else mkIfNoValue true;
            };
          }
          else mkIfNoValue {};
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
      })
      config.user);
  };
}
