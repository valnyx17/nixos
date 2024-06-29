{pkgs, ...}: {
  home.packages = with pkgs; [
    nom
    pinta
    vesktop
    signal-desktop
    vesktop
    blockbench
    blender
    prismlauncher
  ];
}
