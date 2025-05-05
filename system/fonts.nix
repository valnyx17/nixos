{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = false;
    fontconfig = {
      enable = true;
      antialias = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["Sky Term" "Intel One Mono" "Symbols Nerd Font" "Noto Color Emoji"];
        serif = ["Alegreya" "Petrona" "Noto Serif" "Noto Color Emoji"];
        sansSerif = ["Atkinson Hyperlegible" "Overpass" "Nunito" "Noto Color Emoji"];
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
      pkgs.intel-one-mono

      pkgs.material-design-icons
      (pkgs.google-fonts.override {fonts = ["Overpass" "Nunito" "Alegreya" "Petrona" "Atkinson Hyperlegible"];})
      pkgs.unstable.nerd-fonts.symbols-only
    ];
  };
}
