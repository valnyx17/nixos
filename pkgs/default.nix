pkgs: {
  clone = pkgs.callPackage ./clone.nix {};
  disko = pkgs.callPackage ./disko.nix {};
}
