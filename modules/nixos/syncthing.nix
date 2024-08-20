{...}: {services.syncthing = {
    enable = true;
    user = "dv";
    dataDir = "/dv";
    configDir = "/dv/.config/syncthing";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      devices = {
        "truenas" = {
          id = "2HEHVRP-6Z4FBIB-MULQ6Y2-XP2IW6Q-WVOVKOR-HSJBZ3O-RUN7DZI-SAM2SAA";
          autoAcceptFolders = true;
        };
      };
      folders = {
        "Explicit Sync" = {
          path = "/dv/sync";
          devices = ["truenas"];
        };
        "zettelkasten" = {
          path = "/dv/zet";
          devices = ["truenas"];
        };
      };
    };
  };}
