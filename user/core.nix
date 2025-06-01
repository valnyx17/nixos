{pkgs, ...}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      spotify
      wl-clipboard-rs
      transmission_4-qt
      ;
    inherit
      (pkgs.unstable)
      steam-run
      davinci-resolve
      ;
  };
}
