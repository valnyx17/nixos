{pkgs}:
pkgs.writeShellScriptBin "clone" ''
  CLONE_LOCATION=''${1=$HOME/nix}
  ${pkgs.git}/bin/git clone https://github.com/devawaves/nixos $CLONE_LOCATION
''
