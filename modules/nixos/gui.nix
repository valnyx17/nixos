{
  services.xserver.enable = true;
  services.xserver.desktopManager = {
	xterm.enable = false;
	xfce.enable = true;
  };
  services.xserver.displayManager.defaultSession = "xfce";
}
