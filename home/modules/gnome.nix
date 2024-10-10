{
  pkgs,
  ...
}: {
  gtk = {
    enable = true;

    iconTheme = {
      name = "Zafiro-icons-Dark";
      package = pkgs.zafiro-icons;
    };

    # theme = {
    #   name = "Materia-dark";
    #   package = pkgs.materia-theme;
    # };

    cursorTheme = {
      name = "graphite-dark";
      package = pkgs.graphite-cursors;
    };
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;

        enabled-extensions = [
          pkgs.gnomeExtensions.user-themes.extensionUuid
          pkgs.gnomeExtensions.unite.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
        ];
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = "";
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
        picture-uri = "file:///${../dotfiles/alphacoder-1350453.png}";
        picture-uri-dark = "file:///${../dotfiles/alphacoder-1350453.png}";
      };
    };
  };

  home.packages = with pkgs; [
    # Gnome extensions
    gnomeExtensions.unite
    gnomeExtensions.user-themes
    gnomeExtensions.blur-my-shell

    # extensions manager
    gnome-extension-manager

    # Theme
    materia-theme
  ];
}
