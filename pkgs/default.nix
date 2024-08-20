pkgs: {
  disko = pkgs.callPackage ./disko.nix pkgs;
  tokyo-night-tmux = pkgs.callPackage ./tokyo-night-tmux.nix pkgs;
}
