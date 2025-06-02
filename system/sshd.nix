{...}: {
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      UseDns = true;
      X11Forwarding = false;
    };
  };
}
