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
    unstable.nil
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
    unstable.httpie
    ];
}
