{
  pkgs,
  config,
  ...
}: {
  imports = [./util/user.nix ./gnome_support.nix];

  user.me = {
    username = "deva";
    shell = "zsh";
    description = "Deva Waves";
    initialPassword = "12345";
    sudoer = true;
    developer = true;
    extraGroups = ["networkmanager" "audio" "docker" "input" "libvirtd" "plugdev" "video" "adbusers" "uinput"];
    normalUser = true;
    desktopEnvironment = "gnome";
    obs = true;
    authorizedKeys = [
      (builtins.readFile ./id_deva.pub)
    ];
    packages = with pkgs; [
      nom
      pinta
      vesktop
      signal-desktop
      blockbench
      blender
      prismlauncher
      steam
      unstable.koboldcpp
    ];
  };
  user.root = {
    shell = "zsh";
    extraGroups = [];
    authorizedKeys = [
      (builtins.readFile ./id_deva.pub)
    ];
  };
}
