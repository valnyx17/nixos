# Usage

Building NixOS config manually:

```sh
sudo nixos-rebuild --flake .#hostname switch
```

Upgrading the system implies updating the inputs one at a time:

```sh
sudo nix flake lock --update-input <input>
```

or all of them together:

```sh
nix flake update --commit-lock-file
```
