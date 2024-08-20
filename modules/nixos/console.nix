{pkgs, ...}: {
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };
}
