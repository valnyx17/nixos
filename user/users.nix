{pkgs, ...}: {
  users.users.deva = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Deva Waves";
    initialPassword = "12345";
    extraGroups = ["wheel" "networkmanager" "audio" "docker" "input" "libvirtd" "plugdev" "video" "adbusers"];

    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_dev.pub)
    ];
  };

  users.users.root = {
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_dev.pub)
    ];
  };
}
