{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  hm = inputs.home-manager.lib.hm;
in {
  home-manager.users.valerie = {
    # import home-manager modules
    imports = builtins.concatMap import [
      ../modules
    ];

    home = {
      file.".ssh/id_user.pub".text = builtins.readFile ../../system/waves/id_user.pub;
      username = "valerie";
      homeDirectory = "/home/valerie";
      extraOutputsToInstall = ["doc" "devdoc"];
      packages =
        [
          inputs.nh.packages.x86_64-linux.default
          inputs.st.packages.x86_64-linux.st-snazzy
        ]
        ++ (with pkgs; [
          nom
          pinta
          vesktop
          signal-desktop
          blockbench
          blender
          prismlauncher
          unstable.vscode-fhs
        ]);
      sessionVariables = {
        NIX_AUTO_RUN = "1";
        NH_FLAKE = "/home/valerie/nixos";
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
    systemd.user.startServices = "sd-switch";
  };
  xdg.mime = {
    defaultApplications = {
      "applications/zip" = "org.gnome.FileRoller.desktop";
    };
  };
}
