pkgs: pkgs.writeShellScriptBin "disko" ''
  cat >disko.nix <<EOL
  ${builtins.readFile ../disko.nix}
  EOL
''
# pkgs: pkgs.writeShellApplication {
#   name = "disko";
#
#   text = ''
#     cat >disko.nix <<EOL
#     ${builtins.readFile ../disko.nix}
#     EOL
#   '';
# }
