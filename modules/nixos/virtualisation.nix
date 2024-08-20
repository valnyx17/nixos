{config, ...}: {
  virtualisation.containers.cdi.dynamic.nvidia.enable = builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
  virtualisation.vmware.host.enable = true;
  virtualisation.docker.enable = true;
}
