{pkgs, config, ...}: {
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
