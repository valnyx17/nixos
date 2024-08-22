{pkgs, ...}: {
home.packages = [
    pkgs.noto-fonts
    pkgs.noto-fonts-emoji

    pkgs.material-design-icons
    (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito"];})
    (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
  ];
    xsession.windowManager.bspwm = {
        enable = true;
        startupPrograms = [
            "wezterm"
        ];
    };
}
