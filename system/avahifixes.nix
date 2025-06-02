{
  pkgs,
  lib,
  ...
}: {
  # local name resolution
  services.avahi = {
    enable = true;
    openFirewall = true;
    nssmdns4 = true;
  };
  system.nssModules = lib.optional true pkgs.nssmdns;
  system.nssDatabases.hosts = lib.optionals true (pkgs.lib.mkMerge [
    (lib.mkBefore ["mdns4_minimal [NOTFOUND=return]"]) # before resolution
    (lib.mkAfter ["mdns4"]) # after dns
  ]);
}
