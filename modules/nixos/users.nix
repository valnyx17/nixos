{pkgs,...}: {
  users.users.dv = {
    uid = 1337;
    initialPassword = "iamsonaughty.";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_user.pub)
    ];
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "docker"
      "input"
      "libvirtd"
      "plugdev"
      "video"
      "adbusers"
      "uinput"
    ];
  };

  users.users.root = {
    shell = pkgs.zsh;
    extraGroups = [];
    openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_user.pub)
    ];
  };
}
