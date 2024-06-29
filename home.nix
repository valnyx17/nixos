{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  home = {
    username = "deva";
    homeDirectory = "/home/deva";
    extraOutputsToInstall = ["doc" "devdoc"];
    packages = [
      inputs.nh.packages.x86_64-linux.default
    ];
    sessionVariables = {
      NIX_AUTO_RUN = "1";
      FLAKE = "${config.home.homeDirectory}/nix";
    };
  };

  nix.package = pkgs.nixVersions.latest;
  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  manual = {
    html.enable = true;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;
  programs.git.enable = true;
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "24.05";
}
