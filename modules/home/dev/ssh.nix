{programs.ssh = {
      enable = true;
      matchBlocks = {
        "hi@dessa.dev" = {
          host = "gitlab.com github.com 192.168.1.203";
          identitiesOnly = true;
          identityFile = [
            "~/.ssh/id_user"
          ];
        };
      };
    };}
