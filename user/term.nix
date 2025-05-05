{
  config,
  pkgs,
  inputs,
  ...
}: {
  xdg.configFile = {
    "ghostty/config".source = "${../files/ghostty-config}";
  };
  programs = {
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "Tomorrow Night";
        style = "numbers,changes";
        tabs = "2";
        wrap = "never";
      };
      themes = {
        tomorrow-night = {
          src = pkgs.fetchFromGitHub {
            owner = "chriskempson";
            repo = "Tomorrow-Theme";
            rev = "ccf6666d888198d341b26b3a99d0bc96500ad503";
            sha256 = "sha256-G9NOFKP9GX8lKIoHVska6xAY9AKKMenZuVkx0YgfQyA=";
          };
          file = "TextMate/Tomorrow-Night.tmTheme";
        };
      };
    };
    eza.enable = true;
    man.enable = true;
  };
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      #tailspin
      #curlie
      #ouch
      #viddy
      #netscanner
      #kalker
      fd
      ripgrep
      # await
      ghostty
      bottom
      direnv
      ;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  services.gpg-agent.enableZshIntegration = true;

  programs.zsh = let
    emacs_client = ''emacsclient --create-frame --alternate-editor=""'';
  in {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = false;
    autosuggestion.enable = false;
    history = {
      path = "${config.home.homeDirectory}/.cache/.zsh-histfile";
      save = 1000000000;
      size = 100000000;
    };
    initExtraBeforeCompInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' menu no
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion::complete:*' gain-privileges 1
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:+__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':completion:*:git-checkout:*' sort false
      # _comp_options+=(globdots)
      #setopt APPEND_HISTORY            # Append to histfile instead of overwriting.
      setopt SHARE_HISTORY             # Share history between all sessions.
      setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
      #setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
      setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
      setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
      setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
      #setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
      #setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.
      function error() { print -P "%F{red}[ERROR]%f: %F{yellow}$1%f" && return 1 }
      function info() { print -P "%F{blue}[INFO]%f: %F{cyan}$1%f"; }
      typeset -gAH ZINIT;
      ZINIT[HOME_DIR]=''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit  ZPFX=$ZINIT[HOME_DIR]/polaris
      ZINIT[BIN_DIR]=$ZINIT[HOME_DIR]/zinit.git ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
      ZINIT[COMPLETIONS_DIR]=$ZINIT[HOME_DIR]/completions ZINIT[SNIPPETS_DIR]=$ZINIT[HOME_DIR]/snippets
      ZINIT[ZCOMPDUMP_PATH]=$ZINIT[HOME_DIR]/zcompdump    ZINIT[PLUGINS_DIR]=$ZINIT[HOME_DIR]/plugins
      ZI_REPO='zdharma-continuum'
      if [[ ! -e $ZINIT[BIN_DIR] ]]; then
        info 'downloading zinit' \
        && command git clone \
          https://github.com/$ZI_REPO/zinit.git \
          $ZINIT[BIN_DIR] \
        || error 'failed to clone zinit repository' \
        && info 'setting up zinit' \
        && command chmod g-rwX $ZINIT[HOME_DIR] \
        && zcompile $ZINIT[BIN_DIR]/zinit.zsh \
        && info 'sucessfully installed zinit'
      fi
      if [[ -e $ZINIT[BIN_DIR]/zinit.zsh ]]; then
        source $ZINIT[BIN_DIR]/zinit.zsh \
          && autoload -Uz _zinit \
          && (( ''${+_comps} )) \
          && _comps[zinit]=_zinit
      else error "unable to find 'zinit.zsh'" && return 1
      fi
    '';
    initExtra = ''
      zi wait lucid light-mode for \
            Aloxaf/fzf-tab \
        atinit"zicompinit; zicdreplay" \
            zdharma-continuum/fast-syntax-highlighting \
        atload"_zsh_autosuggest_start" \
            zsh-users/zsh-autosuggestions \
        blockf atpull'zinit creisntall -q .' \
            zsh-users/zsh-completions
      zinit cdreplay -q
      bindkey -v
      bindkey "^a" vi-beginning-of-line
      bindkey "^e" vi-end-of-line
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      #bindkey '^f' autosuggest-accept

      while read -r option; do
        setopt $option
      done <<-EOF
      ALWAYS_TO_END
      AUTO_LIST
      AUTO_MENU
      AUTO_PARAM_SLASH
      AUTO_PUSHD
      ALWAYS_TO_END
      COMPLETE_IN_WORD
      EXTENDED_GLOB
      INC_APPEND_HISTORY
      INTERACTIVE_COMMENTS
      MENU_COMPLETE
      NO_BEEP
      NOTIFY
      PATH_DIRS
      PUSHD_IGNORE_DUPS
      PUSHD_SILENT
      EOF
      while read -r option; do
        unsetopt $option
      done <<-EOF
      CASE_GLOB
      CORRECT
      EQUALS
      FLOWCONTROL
      NOMATCH
      EOF

      # prompt init
      zi light mroth/evalcache
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${../files/prompt.json})"
      _evalcache fzf --zsh
      _evalcache zoxide init --cmd cd zsh
      _evalcache direnv hook zsh
      zi for atload'
            zicompinit; zicdreplay
            _zsh_highlight_bind_widgets
            _zsh_autosuggest_bind_widgets' \
          as'null' id-as'zinit/cleanup' lucid nocd wait \
        $ZI_REPO/null
    '';
    dirHashes = {
      dl = "${config.xdg.userDirs.download}";
      docs = "${config.xdg.userDirs.documents}";
      ops = "${config.xdg.userDirs.documents}/ops";
      code = "${config.xdg.userDirs.documents}/ops/code";
      nixos = "/etc/nixos";
      pics = "${config.xdg.userDirs.pictures}";
      vids = "${config.xdg.userDirs.videos}";
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      LC_ALL = "en_US.UTF-8";
      # SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      KEYTIMEOUT = 1;
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin";
      EDITOR = "em";
      ALTERNATE_EDITOR = "emacs --init-directory='~/.demacs.d'";
    };
    shellAliases = {
      fhs = "steam-run";
      nsh = "nix-shell --command 'zsh'";
      nd = "nix develop";
      # tempemacs = "emacs -q --init-directory=`mktemp -d`";
      # also dont forget --debug-init
      em = emacs_client;
      ff = "emacsclient";
      ed = "emacsclient -nw -a=''";
      g = "git";
      gs = "git st";
      gc = "git clone";
      gi = "git init";
      gr = "git sync";
      gd = "git diff --output-indicator-new=' ' --output-indicator-old=' '";
      gdf = "git df --output-indicator-new=' ' --output-indicator-old=' '";
      gp = "git push";
      gl = "git pull";
      ga = "git add";
      gap = "git add --patch";
      gb = "git branch";
      cp = "cp -ri";
      mkdir = "mkdir -p";
      free = "free -m";
      j = "just";
      meteo = "curl http://wttr.in";
      bd = "popd || cd ..";
      cdr = "cd \$(git rev-parse --show-toplevel)";
      ls = "eza -al --icons --no-time --group-directories-first";
      la = "eza -a --icons --no-time --group-directories-first";
      cat = "bat";
      top = "btm";
      glg = "git lg";
      serve = "${pkgs.python3}/bin/python3 -m http.server";
      ytmp3 = "${pkgs.yt-dlp}/bin/yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata --output '%(title)s.%(ext)s'";
    };
  };
}
