{pkgs}:
pkgs.writeShellScriptBin "disko" ''
  ${pkgs.curl}/bin/curl "https://raw.githubusercontent.com/devawaves/nixos/main/disko.nix" -o disko.nix
''
