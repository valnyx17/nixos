{pkgs, ...}: {
  services.avahi = {
    enable = true;
    openFirewall = true;
  };
  system.nssModules = pkgs.lib.optional true pkgs.nssmdns;
  system.nssDatabases.hosts = pkgs.lib.optionals true (pkgs.lib.mkMerge [
    (pkgs.lib.mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolution
    (pkgs.lib.mkAfter ["mdns4"]) # after dns
  ]);
}
