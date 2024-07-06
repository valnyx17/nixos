{pkgs, ...}: {
  imports = [./util/user.nix ./gnome_support.nix];

  user.deva = {
    shell = "zsh";
    description = "Deva Waves";
    initialPassword = "12345";
    sudoer = true;
    developer = true;
    extraGroups = ["networkmanager" "audio" "docker" "input" "libvirtd" "plugdev" "video" "adbusers"];
    normalUser = true;
    desktopEnvironment = "gnome";
    obs = true;
    authorizedKeys = [
      (builtins.readFile ./id_dev.pub)
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
    ];
  };
  user.root = {
    shell = "zsh";
    extraGroups = [];
    authorizedKeys = [
      (builtins.readFile ./id_dev.pub)
    ];
  };
}
