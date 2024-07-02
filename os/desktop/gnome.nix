{
  pkgs,
  config,
  ...
}: {
  dconf = {
    enable = true;

    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;

        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "unite@hardpixel.eu"
        ];
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = "Materia-dark";
      };

      "org/gnome/shell/extensions/unite" = {
        desktop-name-text = "Desktop";
        greyscale-tray-icons = true;
        hide-activities-button = "always";
        hide-window-titlebars = "always";
        show-window-buttons = "always";
        show-window-title = "tiled";
        window-buttons-placement = "first";
        window-buttons-theme = "arc";
      };

      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/wm/preferences" = {
        resize-with-right-button = true;
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>Return";
        command = "kitty";
        name = "Open Terminal";
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file:///${./wallpaper.jpg}";
        picture-uri-dark = "file:///${./nix-wallpaper.png}";
      };
    };
  };

  home.packages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.unite
    gnomeExtensions.user-themes

    # Theme
    materia-theme
  ];
  gtk = {
    enable = true;

    font = {
      name = "Iosevka";
      size = 12;
    };

    iconTheme = {
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;
    };

    theme = {
      name = "Materia-dark";
      package = pkgs.materia-theme;
    };

    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintfull"
        gtk-xft-rgba="rgb"
      '';
    };

    gtk3 = {
      bookmarks = [
        "file://${config.home.homeDirectory}/Documents"
        "file://${config.home.homeDirectory}/Downloads"
        "file://${config.home.homeDirectory}/Music"
        "file://${config.home.homeDirectory}/Pictures"
        "file://${config.home.homeDirectory}/Videos"
      ];

      extraConfig = {
        gtk-application-prefer-dark-theme = 1;

        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
        gtk-xft-rgba = "rgb";
      };
    };

    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  home = {
    sessionVariables = {
      GTK_THEME = config.gtk.theme.name;
    };
  };
}
