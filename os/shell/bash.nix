{
  pkgs,
  config,
  ...
}: {
  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.man.enable = true;

  programs.wezterm.enableBashIntegration = true;
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  services.gpg-agent.enableBashIntegration = true;
  programs.bash = {
    enable = true;
    enableCompletion = true;
    # historyControl = ["erasedups" "ignorespace" "ignoredups" "ignoreboth"]
    historyFile = "${config.home.homeDirectory}/.histfile";
    historyFileSize = 100000000;
    shellOptions = [
      "APPEND_HISTORY" # Append to histfile instead of overwriting.
      "SHARE_HISTORY" # Share history between all sessions.
      "HIST_IGNORE_SPACE" # Do not record an event starting with a space.
      "HIST_IGNORE_ALL_DUPS" # Delete an old recorded event if a new event is a duplicate.
      "HIST_SAVE_NO_DUPS" # Do not write a duplicate event to the history file.
      "HIST_IGNORE_DUPS" # Do not record an event that was just recorded again.
      "HIST_FIND_NO_DUPS" # Do not display a previously found event.
      "EXTENDED_HISTORY" # Write the history file in the ':start:elapsed;command' format.
      "HIST_EXPIRE_DUPS_FIRST" # Expire a duplicate event first when trimming history.

      "ALWAYS_TO_END"
      "ALWAYS_TO_END"
      "AUTO_LIST"
      "AUTO_MENU"
      "AUTO_PARAM_SLASH"
      "AUTO_PUSHD"
      "ALWAYS_TO_END"
      "COMPLETE_IN_WORD"
      "EXTENDED_GLOB"
      "INC_APPEND_HISTORY"
      "INTERACTIVE_COMMENTS"
      "MENU_COMPLETE"
      "NO_BEEP"
      "NOTIFY"
      "PATH_DIRS"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"

      "-CASE_GLOB"
      "-CORRECT"
      "-EQUALS"
      "-FLOWCONTROL"
      "-NOMATCH"
    ];
    initExtra = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd bash)"
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init bash --config ${./prompt-zen.toml})"

      hash -d "dl"="$HOME/Downloads"
      hash -d "docs"="$HOME/Documents"
      hash -d "src"="$HOME/src"
      hash -d "dots"="$HOME/nix"
      hash -d "nix"="$HOME/nix"
      hash -d "pics"="$HOME/Pictures"
      hash -d "vids"="$HOME/Videos"
    '';
    sessionVariables = {
      SAVEHIST = 1000000000;
      HISTDUP = "erase";
      DIRENV_LOG_FORMAT = "";
      LC_ALL = "en_US.UTF-8";
      KEYTIMEOUT = 1;
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin";
    };
    shellAliases = {
      run = "nix-shell --command 'zsh' -p";
      nsh = "nix-shell --command 'zsh'";
      nd = "nix develop";
      g = "git";
      gs = "git st";
      gst = "git st";
      src = "cd $HOME/dev";
      sv0 = "ssh -l root proxmox";
      nmcs = "ssh -l kd nmcs";
      pn = "pnpm";
      rm = "rm -rf";
      cp = "cp -ri";
      mkdir = "mkdir -p";
      free = "free -m";
      j = "just";
      ed = "code";
      n = "nvim";
      cdr = "cd \$(git rev-parse --show-toplevel)";
      l = "eza -al --no-time --group-directories-first";
      ls = "eza -al --no-time --group-directories-first";
      la = "eza -a";
      ll = "eza -l --no-time --group-directories-first";
      lt = "eza -aT --no-time --group-directories-first";
      cat = "bat --theme gruvbox-dark --style numbers,changes --color=always --tabs=2 --wrap=never";
      diff = "delta";
      top = "btm";
      c = "clear";
      glg = "git lg";
      ghr = "gh repo";
      serve = "python3 -m http.server";
      ytmp3 = "yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata --output '%(title)s.%(ext)s'";
    };
  };
}
