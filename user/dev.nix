{
  pkgs,
  config,
  ...
}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs.unstable)
      bruno
      zoxide
      mprocs
      just
      zellij
      ;
  };

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    lfs.enable = true;

    userName = "vivian";
    userEmail = "hi@dessa.dev";
    signing = {
      key = "CC10324DD962CB7E";
      signByDefault = true;
    };

    aliases = {
      wta = "worktree add";
      wtl = "worktree list";
      wtr = "worktree remove";
      rh = "reset HEAD"; # unstages all changes
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
      init.defaultBranch = "dev";
      branch.autosetupmerge = "true";
      push.default = "current";
      merge.stat = "true";
      core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
      repack.usedeltabaseoffset = "true";
      pull.ff = "only";
      core = {
        compression = 9;
        preloadindex = true;
      };
      advice = {
        addEmptyPathSpec = false;
        pushNonFastForward = false;
        statusHints = false;
      };
      url = {
        "git@github.com:solviarose/".insteadOf = "rose:";
        "git@github.com:".insteadOf = "gh:";
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      status = {
        branch = true;
        showStash = true;
        showUntrackedFiles = "all";
      };
      diff = {
        context = 3;
        renames = "copies";
        interHunkContext = 10;
      };
    };
    diff-so-fancy = {
      enable = true;
      markEmptyLines = false;
    };
    ignores = [
      "*~"
      "*.swp"
      "*result*"
      "todo.md"
      "node_modules"
    ];
  };
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      editor = "emacsclient --reuse-frame -a 'emacs'";
      git_protocol = "ssh";
      aliases = {
        co = "pr checkout";
        rc = "repo clone";
        cp = "copilot";
      };
    };
  };
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "hi@dessa.dev" = {
        host = "gitlab.com github.com";
        identitiesOnly = true;
      };
      "docker lmao" = {
        host = "docker 192.168.1.203";
        user = "git";
        port = 2222;
      };
    };
  };
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
    settings = {
      use-agent = true;
      default-key = "CC10324DD962CB7E";
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
    extraPackages = epkgs: [
      epkgs.treesit-grammars.with-all-grammars
      epkgs.vterm
    ];
  };
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    EMACSDIR = "${config.home.homeDirectory}/.emacs.d";
  };

  xdg.configFile."zellij/config.kdl".text = ''
      default_shell "${pkgs.zsh}/bin/zsh"
      show_startup_tips false
      theme "catppuccin-frappe"

      keybinds clear-defaults=true {
        normal {
          bind "Ctrl 1" { CloseTab; }
          bind "Ctrl 2" { NewTab; }
          bind "Ctrl 3" { GoToPreviousTab; }
          bind "Ctrl 4" { GoToNextTab; }
        }
      }

      ui {
        pane_frames {
          hide_session_name false
        }
      }
    '';
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
      pane borderless=false
      pane size=1 borderless=true {
        plugin location="zellij:compact-bar"
      }
    }
    pane_frames false
  '';
}
