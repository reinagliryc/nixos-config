{ config, pkgs, ... }:

{

  services.photoprism = {
    enable = true;
    originalsPath = "/data/photos";
    settings = {
#      PHOTOPRISM_ADMIN_USER = "root";
      PHOTOPRISM_AUTH_MODE = "public";
#      PHOTOPRISM_LOG_LEVEL = "debug";
      PHOTOPRISM_READONLY = "TRUE";
#      PHOTOPRISM_DEBUG = "TRUE";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
    };
    passwordFile = "/var/lib/secrets/photoprism_admin";
  };

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [ 
      {
        name = "photoprism";
        ensurePermissions = {
          "photoprism.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
