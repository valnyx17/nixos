{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs.unstable; [
    bruno
    xclip
    just
    nixd
    alejandra
    zoxide
    neovide
    nodejs
    corepack
    cargo-watch
    rustup
    gcc
    go
    jetbrains.idea-community
    cascadia-code
    jdk17
    # lua
    lua51Packages.lua
    tree-sitter
    luarocks
    gnumake
    ast-grep
    ncdu
    gh-dash
    hurl
    jnv
    rustscan
    slides
    markdownlint-cli2
    fx
    jq
    deno
    gleam
    unzip
    porsmo
    mprocs

    transmission_4-gtk
  ];

  # git
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        showFileTree = true;
        theme = {
          activeBorderColor = ["magenta" "bold"];
          inactiveBorderColor = ["black"];
        };
      };
      os = {
        editCommand = "nvim";
        editCommandTemplate = "{{editor}} {{filename}}";
      };
      keybinding.universal = {
        quit = "q";
      };
    };
  };
  programs.gitui = {
    enable = false;
    keyConfig = ''
      (
          move_left: Some(( code: Char('h'), modifiers: "")),
          move_right: Some(( code: Char('l'), modifiers: "")),
          move_up: Some(( code: Char('k'), modifiers: "")),
          move_down: Some(( code: Char('j'), modifiers: "")),

          stash_open: Some(( code: Char('l'), modifiers: "")),
          open_help: Some(( code: F(1), modifiers: "")),

          status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),
      )
    '';
  };
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    lfs.enable = true;

    userName = "valerie";
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
      "todo.md"
      "node_modules"
    ];
  };
  programs.gh = {
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

  # ssh
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "hi@dessa.dev" = {
        host = "gitlab.com github.com";
        identitiesOnly = true;
        identityFile = [
          "~/.ssh/id_user"
        ];
      };
      "docker lmao" = {
        host = "docker 192.168.1.203";
        user = "git";
        port = 2222;
        identityFile = [
          "~/.ssh/id_user"
        ];
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
    pinentryPackage = pkgs.pinentry-gnome3;
  };
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
  };
}
