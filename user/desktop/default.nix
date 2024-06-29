{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./gnome.nix
  ];

  home.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-emoji

    pkgs.material-design-icons
    (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito"];})
    (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];

  home.pointerCursor = {
    package = pkgs.graphite-cursors;
    name = "graphite-dark";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  home.sessionVariables = {
    XCURSOR_SIZE = config.home.pointerCursor.size;
    XCURSOR_THEME = config.home.pointerCursor.name;
  };
}
