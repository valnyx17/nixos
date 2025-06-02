# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../../../../system/sops.nix
  ];

  # Containers
  virtualisation.oci-containers.containers."pterodactyl-cache" = {
    image = "redis:alpine";
    log-driver = "journald";
    extraOptions = [
      "--network-alias=cache"
      "--network=pterodactyl_default"
    ];
  };

  systemd.services."docker-pterodactyl-cache" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pterodactyl_default.service"
    ];
    requires = [
      "docker-network-pterodactyl_default.service"
    ];
    partOf = [
      "docker-compose-pterodactyl-root.target"
    ];
    wantedBy = [
      "docker-compose-pterodactyl-root.target"
    ];
  };

  virtualisation.oci-containers.containers."pterodactyl-database" = {
    image = "mariadb:10.11";
    environmentFiles = [config.sops.secrets.pterodactyl_db_docker_env.path];
    environment = {
      "MYSQL_DATABASE" = "panel";
      "MYSQL_RANDOM_ROOT_PASSWORD" = "true";
      "MYSQL_USER" = "pterodactyl";
    };
    volumes = [
      "pterodactyl_db:/var/lib/mysql:rw"
    ];
    cmd = ["--default-authentication-plugin=mysql_native_password"];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=database"
      "--network=pterodactyl_default"
    ];
  };

  systemd.services."docker-pterodactyl-database" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pterodactyl_default.service"
      "docker-volume-pterodactyl_db.service"
    ];
    requires = [
      "docker-network-pterodactyl_default.service"
      "docker-volume-pterodactyl_db.service"
    ];
    partOf = [
      "docker-compose-pterodactyl-root.target"
    ];
    wantedBy = [
      "docker-compose-pterodactyl-root.target"
    ];
  };

  virtualisation.oci-containers.containers."pterodactyl-panel" = {
    image = "ghcr.io/pterodactyl/panel:latest";
    environmentFiles = [config.sops.secrets.pterodactyl_pterodactyl_docker_env.path];
    environment = {
      "APP_ENV" = "production";
      "APP_ENVIRONMENT_ONLY" = "false";
      "APP_SERVICE_AUTHOR" = "rose@solvia.dev";
      "APP_TIMEZONE" = "America/Indiana/Indianapolis";
      "APP_URL" = "https://pterodactyl.internal.solvia.dev";
      "CACHE_DRIVER" = "redis";
      "DB_HOST" = "database";
      "DB_PORT" = "3306";
      "QUEUE_DRIVER" = "redis";
      "REDIS_HOST" = "cache";
      "SESSION_DRIVER" = "redis";
      "TRUSTED_PROXIES" = "*";
    };
    volumes = [
      "pterodactyl_ptero_logs:/app/storage/logs:rw"
      "pterodactyl_ptero_var:/app/var:rw"
    ];
    labels = {
      "traefik.http.routers.pterodactylinternalsolviadev.rule" = "Host(`pterodactyl.internal.solvia.dev`)";
    };
    dependsOn = [
      "pterodactyl-cache"
      "pterodactyl-database"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=panel"
      "--network=pterodactyl_default"
    ];
  };

  systemd.services."docker-pterodactyl-panel" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pterodactyl_default.service"
      "docker-volume-pterodactyl_ptero_logs.service"
      "docker-volume-pterodactyl_ptero_var.service"
    ];
    requires = [
      "docker-network-pterodactyl_default.service"
      "docker-volume-pterodactyl_ptero_logs.service"
      "docker-volume-pterodactyl_ptero_var.service"
    ];
    partOf = [
      "docker-compose-pterodactyl-root.target"
    ];
    wantedBy = [
      "docker-compose-pterodactyl-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-pterodactyl_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f pterodactyl_default";
    };
    script = ''
      docker network inspect pterodactyl_default || docker network create pterodactyl_default
    '';
    partOf = ["docker-compose-pterodactyl-root.target"];
    wantedBy = ["docker-compose-pterodactyl-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-pterodactyl_db" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect pterodactyl_db || docker volume create pterodactyl_db
    '';
    partOf = ["docker-compose-pterodactyl-root.target"];
    wantedBy = ["docker-compose-pterodactyl-root.target"];
  };

  systemd.services."docker-volume-pterodactyl_ptero_logs" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect pterodactyl_ptero_logs || docker volume create pterodactyl_ptero_logs
    '';
    partOf = ["docker-compose-pterodactyl-root.target"];
    wantedBy = ["docker-compose-pterodactyl-root.target"];
  };

  systemd.services."docker-volume-pterodactyl_ptero_var" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect pterodactyl_ptero_var || docker volume create pterodactyl_ptero_var
    '';
    partOf = ["docker-compose-pterodactyl-root.target"];
    wantedBy = ["docker-compose-pterodactyl-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-pterodactyl-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
