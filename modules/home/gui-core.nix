{pkgs, ...}: {
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    material-design-icons
    cozette
    (google-fonts.override {fonts = ["Overpass" "Nunito"];})
    (nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];
}
