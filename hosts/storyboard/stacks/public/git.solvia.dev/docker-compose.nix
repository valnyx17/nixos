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
  virtualisation.oci-containers.containers."forgejo-db" = {
    image = "postgres:17.4";
    environmentFiles = [config.sops.secrets.forgejo_db_docker_env.path];
    environment = {
      "POSTGRES_DB" = "forgejo";
      "POSTGRES_USER" = "forgejo";
    };
    volumes = [
      "forgejo_db:/var/lib/postgresql/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=db"
      "--network=forgejo_default"
    ];
  };

  systemd.services."docker-forgejo-db" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_db.service"
    ];
    requires = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_db.service"
    ];
    partOf = [
      "docker-compose-forgejo-root.target"
    ];
    wantedBy = [
      "docker-compose-forgejo-root.target"
    ];
  };

  virtualisation.oci-containers.containers."forgejo-redis" = {
    image = "redis:8.0.0";
    volumes = [
      "forgejo_redis:/data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=redis"
      "--network=forgejo_default"
    ];
  };

  systemd.services."docker-forgejo-redis" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_redis.service"
    ];
    requires = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_redis.service"
    ];
    partOf = [
      "docker-compose-forgejo-root.target"
    ];
    wantedBy = [
      "docker-compose-forgejo-root.target"
    ];
  };

  virtualisation.oci-containers.containers."forgejo-server" = {
    image = "codeberg.org/forgejo/forgejo:11";
    environmentFiles = [config.sops.secrets.forgejo_server_docker_env.path];
    environment = {
      "FORGEJO__cache__ADAPTER" = "redis";
      "FORGEJO__cache__ENABLED" = "true";
      "FORGEJO__cache__HOST" = "redis://redis:6379/0?pool_size=100&idle_timeout=180s";
      "FORGEJO__database__DB_TYPE" = "postgres";
      "FORGEJO__database__HOST" = "db:5432";
      "FORGEJO__database__NAME" = "forgejo";
      "FORGEJO__database__USER" = "forgejo";
      "FORGEJO__service__REGISTER_EMAIL_CONFIRM" = "false";
      "FORGEJO__service__REQUIRE_CAPTCHA_FOR_LOGIN" = "true";
      "FORGEJO__service__REGISTER_MANUAL_CONFIRM" = "true";
      "FORGEJO__service__REQUIRE_EXTERNAL_REGISTRATION_CAPTCHA" = "true";
      "USER_GID" = "1000";
      "USER_UID" = "1000";
    };
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/etc/timezone:/etc/timezone:ro"
      "forgejo_forgejo:/data:rw"
    ];
    ports = [
      "222:22/tcp"
    ];
    labels = {
      "traefik.http.routers.gitsolviadev.rule" = "Host(`git.solvia.dev`)";
      "traefik.http.services.gitsolviadev.loadbalancer.server.port" = "3000";
    };
    dependsOn = [
      "forgejo-db"
      "forgejo-redis"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=server"
      "--network=forgejo_default"
    ];
  };

  systemd.services."docker-forgejo-server" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_forgejo.service"
    ];
    requires = [
      "docker-network-forgejo_default.service"
      "docker-volume-forgejo_forgejo.service"
    ];
    partOf = [
      "docker-compose-forgejo-root.target"
    ];
    wantedBy = [
      "docker-compose-forgejo-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-forgejo_default" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f forgejo_default";
    };
    script = ''
      docker network inspect forgejo_default || docker network create forgejo_default
    '';
    partOf = ["docker-compose-forgejo-root.target"];
    wantedBy = ["docker-compose-forgejo-root.target"];
  };

  # Volumes
  systemd.services."docker-volume-forgejo_db" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect forgejo_db || docker volume create forgejo_db
    '';
    partOf = ["docker-compose-forgejo-root.target"];
    wantedBy = ["docker-compose-forgejo-root.target"];
  };

  systemd.services."docker-volume-forgejo_forgejo" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect forgejo_forgejo || docker volume create forgejo_forgejo
    '';
    partOf = ["docker-compose-forgejo-root.target"];
    wantedBy = ["docker-compose-forgejo-root.target"];
  };

  systemd.services."docker-volume-forgejo_redis" = {
    path = [pkgs.docker];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect forgejo_redis || docker volume create forgejo_redis
    '';
    partOf = ["docker-compose-forgejo-root.target"];
    wantedBy = ["docker-compose-forgejo-root.target"];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-forgejo-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = ["multi-user.target"];
  };
}
