{...}: {
  security = {
    # don't ask password for wheel group, disk is encrypted with a secure password & ssh auth with password is disabled!
    sudo.wheelNeedsPassword = false;
    # enable trusted platform module 2 support
    tpm2.enable = true;
  };
}
