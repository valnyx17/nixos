{...}: {
    programs.niri.config = ''
        window-rule {
            match app-id=r#"^org\.wezfurlong\.wezterm$"#
            default-column-width {}
        }

        binds {
            Super+T { spawn "wezterm"; }
        }
    '';
}
