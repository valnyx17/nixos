{...}: {
  imports = [
    ./ssh.nix
    ./sound.nix
  ];

  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.libinput.enable = true;
  services.printing.enable = true;
}
