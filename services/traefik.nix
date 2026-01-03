{ config, pkgs, ... }:

{
  services.traefik.enable = true;

  ##############################################################################
  # Static config (entrypoints, ACME resolver, http→https)
  ##############################################################################
  services.traefik.staticConfigOptions.api.dashboard = true;
  services.traefik.staticConfigOptions.entryPoints.web.address = ":80";
  services.traefik.staticConfigOptions.entryPoints.web.http.redirections.entryPoint.to = "websecure";
  services.traefik.staticConfigOptions.entryPoints.web.http.redirections.entryPoint.scheme = "https";
  services.traefik.staticConfigOptions.entryPoints.web.http.redirections.entryPoint.permanent = true;

  services.traefik.staticConfigOptions.entryPoints.websecure.address = ":443";

  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.email = "cyril@ganier.fr";
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.storage = "/var/lib/acme/acme.json";
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.provider = "infomaniak";
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.propagation.disableANSChecks = true;
  services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.propagation.delayBeforeChecks = 180;
  #services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.dnsChallenge.delayBeforeCheck = 180;

  ##############################################################################
  # Dynamic config (routers, services, TLS policy)
  ##############################################################################
  services.traefik.dynamicConfigOptions.http.routers.hass.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.hass.rule = "Host(`hass.ganier.fr`)";
  services.traefik.dynamicConfigOptions.http.routers.hass.service = "hass";
  services.traefik.dynamicConfigOptions.http.routers.hass.tls = { };
  services.traefik.dynamicConfigOptions.http.services.hass.loadBalancer.servers = [ { url = "http://127.0.0.1:8123/"; } ];
  services.traefik.dynamicConfigOptions.http.middlewares.syncthing-host.headers.customRequestHeaders.Host = "127.0.0.1";
  services.traefik.dynamicConfigOptions.http.routers.syncthing.middlewares = [ "syncthing-host" ];

  services.traefik.dynamicConfigOptions.http.routers.photoprism.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.photoprism.rule = "Host(`photoprism.ganier.fr`)";
  services.traefik.dynamicConfigOptions.http.routers.photoprism.service = "photoprism";
  services.traefik.dynamicConfigOptions.http.routers.photoprism.tls = { };
  services.traefik.dynamicConfigOptions.http.services.photoprism.loadBalancer.servers = [ { url = "http://127.0.0.1:2342/"; } ];

  services.traefik.dynamicConfigOptions.http.routers.syncthing.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.syncthing.rule = "Host(`syncthing.ganier.fr`)";
  services.traefik.dynamicConfigOptions.http.routers.syncthing.service = "syncthing";
  services.traefik.dynamicConfigOptions.http.routers.syncthing.tls = { };
  services.traefik.dynamicConfigOptions.http.services.syncthing.loadBalancer.servers = [ { url = "http://127.0.0.1:8384/"; } ];

  # Root router triggers wildcard issuance (ganier.fr + *.ganier.fr)
  services.traefik.dynamicConfigOptions.http.routers.root.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.root.rule = "Host(`ganier.fr`)";
  services.traefik.dynamicConfigOptions.http.routers.root.service = "root";
  services.traefik.dynamicConfigOptions.http.routers.root.tls.certResolver = "letsencrypt";
  services.traefik.dynamicConfigOptions.http.routers.root.tls.domains = [ { main = "ganier.fr"; sans = [ "*.ganier.fr" ]; } ];
  services.traefik.dynamicConfigOptions.http.services.root.loadBalancer.servers = [ { url = "http://127.0.0.1:8081/"; } ];

  services.traefik.dynamicConfigOptions.http.routers.dashboard.entryPoints = [ "websecure" ];
  services.traefik.dynamicConfigOptions.http.routers.dashboard.rule = "Host(`traefik.ganier.fr`)";
  services.traefik.dynamicConfigOptions.http.routers.dashboard.service = "api@internal";
  services.traefik.dynamicConfigOptions.http.routers.dashboard.tls = { };


  # TLS options (hardened)
  services.traefik.dynamicConfigOptions.tls.options.default.minVersion = "VersionTLS13";

  ##############################################################################
  # Environment (Infomaniak DNS API token for DNS-01)
  ##############################################################################
  systemd.services.traefik.serviceConfig.EnvironmentFile = "/var/lib/secrets/traefik.env";

  ##############################################################################
  # (Recommended) file permissions for ACME storage
  ##############################################################################
  systemd.tmpfiles.rules = [
    "d /var/lib/acme 0750 traefik traefik -"
    "f /var/lib/acme/acme.json 0600 traefik traefik -"
  ];
}
