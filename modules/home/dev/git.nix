{pkgs, ...}: {
    programs.gitui = {
      enable = true;
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

      userName = "deva";
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
}
