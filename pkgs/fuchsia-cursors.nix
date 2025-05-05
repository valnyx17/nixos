{
  lib,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "fuchsia-cursors";
  version = "2.0.1";
  src = builtins.fetchTarball {
    url = "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.1/fuchsia-all.tar.xz";
    sha256 = "1qvrbs6f8fj275r9q22qi1d7lmqs8b9ckcmwhvghqx9nq9la3xag";
  };
  buildPhase = "";
  installPhase = ''
    mkdir -p $out/share/icons
    mv Fuchsia Fuchsia-Amber Fuchsia-Pop Fuchsia-Red $out/share/icons
  '';
}
