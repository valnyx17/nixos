pkgs: {
  clone = pkgs.callPackage ./clone.nix {};
  disko = pkgs.callPackage ./disko.nix {};
  zed-fhs = pkgs.callPackage ./zed-fhs.nix {};
}
