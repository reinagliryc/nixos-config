{ config, pkgs, ... }:

{

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "nextcloud.ganier.fr";
    # Use HTTPS for links
    https = true;
    enableBrokenCiphersForSSE = false; 
    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "05:00:00";

    config = {
      # Further forces Nextcloud to use HTTPS
      #overwriteProtocol = "https";
      trustedProxies = [ "127.0.0.1" ];
      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
#      dbpassFile = "/var/lib/nextcloud-db-pass";

      adminpassFile = "/var/lib/nextcloud-admin-pass";
      adminuser = "admin";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."nextcloud.ganier.fr".listen = [ { addr = "127.0.0.1"; port = 8484; } ];
  };
}
