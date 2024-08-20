{...}: {
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      UseDns = true;
      X11Forwarding = false;
    };
  };
}
