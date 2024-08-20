{
programs = {
    less.enable = true;

    # default zsh config if not configured using home-manager
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      promptInit = ''
        PS1='%B%1~%b %(#.#.$): '
      '';
    };
  };
  environment.pathsToLink = ["/share/zsh"];
}
