{pkgs, ...}: {
  qt = {
    enable = true;
  };

  home.pointerCursor = {
    package = pkgs.fuchsia-cursors;
    x11.enable = true;
    x11.defaultCursor = "Fuchsia";
    gtk.enable = true;
    name = "Fuchsia";
    size = 20;
  };
}
