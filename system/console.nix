{
  pkgs,
  lib,
  ...
}: {
  # console
  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  programs = {
    less.enable = true;

    # default zsh config if not configured using home-manager
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = false;
      promptInit = ''
        PS1='%B%1~%b %(#.#.$): '
      '';
    };
  };
  environment.pathsToLink = ["/share/zsh"];
}
