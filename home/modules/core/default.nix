{pkgs, ...}: {
  services.gnome-keyring = {
    enable = true;
    components = ["secrets" "ssh"];
  };
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
    ];
  };
}
