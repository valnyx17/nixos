{pkgs, ...}: {
    imports = [
        ./git.nix
        ./ssh.nix
        ./gpg.nix
    ];

    home.packages = with pkgs; [
    unstable.bruno
    unstable.xclip
    unstable.just
    unstable.nixd
    unstable.alejandra
    unstable.zoxide
    unstable.neovide
    unstable.nodejs
    unstable.corepack
    unstable.cargo-watch
    unstable.rustup
    unstable.gcc
    unstable.go
    unstable.jetbrains.idea-community
    unstable.cascadia-code
    unstable.jdk17
    unstable.ncdu
        unstable.gh-dash
        unstable.hurl
        unstable.jnv
        unstable.rustscan
        unstable.slides
    ];
}
