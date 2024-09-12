{pkgs, ...}: {
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages =
    (with pkgs; [
      # for packages that are pkgs.*
      gnome-tour
      gnome-connections
    ])
    ++ (with pkgs.gnome; [
      # for packages that are pkgs.gnome.*
      epiphany # web browser
      geary # email reader
      evince # document viewer
    ]);

  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  programs.hyprland.xwayland.enable = true;
}
