{pkgs}: pkgs.buildFHSUserEnv {
  name = "zed";
  targetPkgs = pkgs: with pkgs; [
    unstable.zed-editor
  ];
  runScript = "zed";
  desktopItem = pkgs.lib.makeDesktopItem {
    name = "zed";
    desktopName = "Zed";
    comment = "A high-performance, multiplayer code editor.";
    genericName = "Text Editor";
    exec = "zed %U";
    icon = "zed";
    startupNotify = true;
    startupWMClass = "zed";
    mimeTypes = ["text/plain" "inode/directory"];
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    keywords = [ "zed" ];
  };
}
