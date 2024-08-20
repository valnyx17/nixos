pkgs: pkgs.writeShellScriptBin "disko" ''
  cat >disko.nix <<EOL
  ${builtins.readFile ../disko.nix}
  EOL
''
