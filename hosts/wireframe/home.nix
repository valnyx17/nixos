{
  pkgs,
  lib,
  config,
  inputs,
  outputs,
  ...
}: {
  imports =
    [
      inputs.sops-nix.homeManagerModules.sops
    ]
    ++ builtins.concatMap import [
      ../../user/v.nix
    ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = ../../secrets/secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "private_keys/user" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };
    };
  };

  home = {
    file.".ssh/id_ed25519.pub".text = builtins.readFile ../../files/id_user.pub;
    stateVersion = "24.11";
    username = "v";
    homeDirectory = "/home/${config.home.username}";
    extraOutputsToInstall = ["doc" "devdoc"];
    packages =
      [
        inputs.zen-browser.packages.x86_64-linux.default
        (pkgs.discord.override {
          withOpenASAR = false;
          withVencord = true;
        })
      ]
      ++ builtins.attrValues {
        inherit
          (pkgs)
          signal-desktop
          element-desktop
          pinta
          ;
        inherit
          (pkgs.unstable)
          prismlauncher
          ;
      };
    sessionVariables = {
      NIX_AUTO_RUN = "1";
    };
  };
  nix.package = lib.mkForce pkgs.unstable.nixVersions.latest;
  nix.extraOptions = ''experimental-features = nix-command flakes'';
  manual = {
    html.enable = true;
    json.enable = false;
    manpages.enable = false;
  };
  programs.home-manager.enable = true;
  programs.git.enable = true;
  services.lorri.enable = true;
  systemd.user.startServices = "sd-switch";
}
