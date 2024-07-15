# USED IN OVERLAY
{
  pkgs,
  lib,
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "tokyo-night-tmux";
  version = "c3bc283cceeefaa7e5896878fe20711f466ab591";
  src = pkgs.fetchFromGitHub {
    owner = "janoamaral";
    repo = "tokyo-night-tmux";
    rev = "c3bc283cceeefaa7e5896878fe20711f466ab591";
    hash = "sha256-3rMYYzzSS2jaAMLjcQoKreE0oo4VWF9dZgDtABCUOtY=";
  };
  rtpFilePath = "tokyo-night.tmux";
  meta = {
    homepage = "https://github.com/janoamaral/tokyo-night-tmux";
    description = "tokyo night tmux theme";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
