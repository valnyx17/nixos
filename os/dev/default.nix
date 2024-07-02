{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs.unstable; [
    bruno
    just
    nil
    alejandra
    zoxide
    neovide
    nodejs
    corepack
    cargo-watch
    rustup

    jetbrains.idea-community
    vscode
    cascadia-code
    jdk17
    ncdu
    httpie
  ];

  programs = {
    wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm.lua;
      colorSchemes = {
        oxocarbon-dark = builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub {
            owner = "nyoom-engineering";
            repo = "oxocarbon-wezterm";
            rev = "b435c308403816db6fec6b87370223e8e8fbb6f4";
            hash = "sha256-KsAoWQVWBHbmimw3Z9kj9j1wnFdLquzi64WP5mEjRzo=";
          }
          + "/oxocarbon-dark.toml"));
      };
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
    ssh = {
      enable = true;
      matchBlocks = {
        "hi@dessa.dev" = {
          host = "gitlab.com github.com";
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/id_dev"
          ];
        };
        "dess_key" = {
          host = "192.168.1.203";
          identitiesOnly = true;
          identityFile = ["~/.ssh/id_dess"];
        };
      };
    };
    gpg = {
      enable = true;
      homedir = "${config.home.homeDirectory}/.gnupg";
      settings = {
        use-agent = true;
        default-key = "CC10324DD962CB7E";
      };
    };
    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      lfs.enable = true;

      userName = "deva";
      userEmail = "hi@dessa.dev";
      signing = {
        key = "CC10324DD962CB7E";
        signByDefault = true;
      };

      aliases = {
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
        lgb = "--no-pager log --oneline --decorate --graph --parents --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --";
        nuke = "!git clean -xdf && git reset --hard && git pull";
        st = "status -sb";
        sync = "!git push && git pull";
        rs = "restore --staged";
        ll = "log --oneline";
        last = "log -1 HEAD --stat";
        cm = "commit -m";
        co = "checkout";
        rv = "remote -v";
        df = "diff HEAD";
      };

      extraConfig = {
        init.defaultBranch = "main";
        branch.autosetupmerge = "true";
        push.default = "current";
        merge.stat = "true";
        core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        repack.usedeltabaseoffset = "true";
        pull.ff = "only";
        rebase = {
          autoSquash = true;
          autoStash = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
      };
      ignores = [
        "*~"
        "*.swp"
        "*result*"
        ".direnv"
        "todo.md"
        "node_modules"
      ];
    };
    gh = {
      enable = true;
      extensions = [
        pkgs.gh-copilot
      ];
      gitCredentialHelper.enable = true;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
        aliases = {
          co = "pr checkout";
          rc = "repo clone";
          cp = "copilot";
        };
      };
    };
    tmux = {
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
            set -g @tokyo-night-tmux_show_datetime 0
            set -g @tokyo-night-tmux_show_path 1
            set -g @tokyo-night-tmux_path_format relative
            set -g @tokyo-night-tmux_window_id_style dsquare
            set -g @tokyo-night-tmux_window_id_style dsquare
            set -g @tokyo-night-tmux_show_git 0
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
  };
  xdg.configFile."lf/icons".source = ./lf-icons;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
}
