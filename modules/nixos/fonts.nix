{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Rec Mono Waves" "Symbols Nerd Font" "Noto Color Emoji"];
        serif = ["Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Overpass" "Nunito" "Noto Color Emoji"];
      };
      hinting = {
        enable = true;
        autohint = false;
        style = "full";
      };
      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };
    };
    fontDir = {
      enable = true;
      decompressFonts = true;
    };
    packages = [
      pkgs.noto-fonts
      pkgs.noto-fonts-emoji

      pkgs.material-design-icons
      (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito"];})
      (pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
    ];
  };
}
