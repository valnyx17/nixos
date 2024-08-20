{
    config,
    pkgs,
    ...
}: let
  pst = pkgs.writeShellScriptBin "pst" (builtins.readFile ./pst);
in {
    programs = {
wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm.lua;
    };
    lf = {
      enable = true;
      commands = {
        dragon-out = ''%${pkgs.xdragon}/bin/xdragon -a -x "$fx"'';
        editor-open = ''$$EDITOR $f'';
        mkdir = ''
          ''${{
            printf "Directory Name: "
            read DIR
            mkdir $DIR
          }}
        '';
      };
      keybindings = {
        "\\\"" = "";
        o = "";
        c = "mkdir";
        D = ''$rm -fr "$fx"'';
        "." = "set hidden!";
        "`" = "mark-load";
        "\\'" = "mark-load";
        "<enter>" = "open";
        do = "dragon-out";
        "g~" = "cd";
        gh = "cd";
        "g/" = "/";
        ee = "editor-open";
        V = ''''$${pkgs.bat}/bin/bat --paging=always --theme=gruvbox "$f"'';
      };
      settings = {
        preview = true;
        hidden = true;
        drawbox = true;
        icons = true;
        ignorecase = true;
      };
      extraConfig = let
        previewer = pkgs.writeShellScriptBin "pv.sh" ''
          file=$1
          w=$2
          h=$3
          x=$4
          y=$5

          if [[ "$( ${pkgs.file}/bin/file -Lb --mime-type "$file")" =~ ^image ]]; then
            # ${pkgs.kitty}/bin/kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
            exit 1
          fi

          ${pkgs.pistol}/bin/pistol "$file"
        '';
        cleaner = pkgs.writeShellScriptBin "clean.sh" ''
          # ${pkgs.kitty}/bin/kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        '';
      in ''
        set cleaner ${cleaner}/bin/clean.sh
        set previewer ${previewer}/bin/pv.sh
      '';
    };
tmux = {
      enable = true;
      mouse = true;
      prefix = "C-Space";
      keyMode = "vi";
      baseIndex = 1;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        yank
        {
          plugin = tokyo-night-tmux;
          extraConfig = ''
# tokyo night tmux config
set -g @tokyo-night-tmux_theme "night"
set -g @tokyo-night-tmux_show_datetime 0
set -g @tokyo-night-tmux_path_format relative
set -g @tokyo-night-tmux_window_id_style digital
set -g @tokyo-night-tmux_pane_id_style hide
set -g @tokyo-night-tmux_show_git 0

# Undercurl fixes (tokyonight.nvim)
set -g default-terminal "${TERM}"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm' # undercurl support
set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m' # underscore colours - needs tmux 3.0
          '';
        }
      ];
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Use Alt-arrow keys without prefix key to switch panes
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        # Shift arrow to switch windows
        bind -n S-Left  previous-window
        bind -n S-Right next-window

        # Shift Alt vim keys to switch windows
        bind -n M-H previous-window
        bind -n M-L next-window

        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind '_' split-window -v -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
      '';
    };
xdg.configFile."lf/icons".source = ./lf-icons;
    };
    programs.bat.enable = true;
  programs.eza.enable = true;
  programs.man.enable = true;
  home.packages = [
    pkgs.unstable.steam-run
    pkgs.delta
    pkgs.bottom
  ];

  programs.wezterm.enableZshIntegration = true;
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  services.gpg-agent.enableZshIntegration = true;
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    enableCompletion = true;
    history = {
      path = "${config.home.homeDirectory}/.histfile";
      save = 1000000000;
      size = 100000000;
    };
    initExtraBeforeCompInit = ''
      # zstyle ':completion:*' menu select
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
    '';
    initExtra = ''
      	setopt APPEND_HISTORY            # Append to histfile instead of overwriting.
      	setopt SHARE_HISTORY             # Share history between all sessions.
      	setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space.
      	setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate.
      	setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file.
      	setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again.
      	setopt HIST_FIND_NO_DUPS         # Do not display a previously found event.
      	setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
      	setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history.

      # Set the directory we want to store zinit (and plugins) in
      # The XDG_DATA_HOME:-$HOME... line chooses XDG_DATA_HOME if it exists, otherwise .local/share
      ZINIT_HOME="''${XDG_DATA_HOME:-''${HOME}/.local/share}/zinit/zinit.git"

      # download zinit if it doesn't exist
      if [ ! -d "$ZINIT_HOME" ]; then
          mkdir -p "$(dirname $ZINIT_HOME)"
          git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
      fi

      # load zinit
      source "''${ZINIT_HOME}/zinit.zsh"

      #region plugins
      zinit light zsh-users/zsh-completions
      autoload -U compinit && compinit
      eval "$(fzf --zsh)"
      zinit light Aloxaf/fzf-tab
      zinit light zsh-users/zsh-syntax-highlighting
      zinit light zsh-users/zsh-autosuggestions

      # snippets
      zinit snippet OMZP::git
      zinit snippet OMZP::sudo
      zinit snippet OMZP::debian
      zinit snippet OMZP::command-not-found
      zinit snippet OMZP::extract

      zinit cdreplay -q
      eval "$(zoxide init --cmd cd zsh)"
      #endregion

      #region setopts
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
      #endregion

      # bindkey -v
      # zmodload zsh/complist
      # bindkey -M menuselect 'h' vi-backward-char
      # bindkey -M menuselect 'k' vi-up-line-or-history
      # bindkey -M menuselect 'l' vi-forward-char
      # bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey "^a" vi-beginning-of-line
      bindkey "^e" vi-end-of-line
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey '^f' autosuggest-accept
      bindkey -M emacs '^[^[' sudo-command-line
      bindkey -M vicmd '^[^[' sudo-command-line
      bindkey -M viins '^[^[' sudo-command-line

      # prompt init
      eval "$(${pkgs.oh-my-posh}/bin/oh-my-posh init zsh --config ${./prompt.json})"
    '';
    dirHashes = {
      dl = "${config.home.homeDirectory}/Downloads";
      docs = "${config.home.homeDirectory}/Documents";
      src = "${config.home.homeDirectory}/src";
      dots = "${config.home.homeDirectory}/nix";
      nix = "${config.home.homeDirectory}/nix";
      pics = "${config.home.homeDirectory}/Pictures";
      vids = "${config.home.homeDirectory}/Videos";
    };
    sessionVariables = {
      DIRENV_LOG_FORMAT = "";
      LC_ALL = "en_US.UTF-8";
      # SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";
      KEYTIMEOUT = 1;
      GPG_TTY = "$(tty)";
      PATH = "$PATH:$HOME/bin";
      # FLAKE = "$HOME/sysconf/nix";
    };
    shellAliases = {
      run = "nix-shell --command 'zsh' -p";
      fhs = "steam-run";
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
      c = "code";
      cr = "code -r";
      cw = "code --wait";
      glg = "git lg";
      serve = "python3 -m http.server";
      ytmp3 = "yt-dlp --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --embed-metadata --output '%(title)s.%(ext)s'";
      pst = "${pst}/bin/pst";
    };
  };
}