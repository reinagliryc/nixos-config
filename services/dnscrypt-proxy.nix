{ config, ... }:

{
  networking = {
    nameservers = [ "127.0.0.1" ];
    # If using dhcpcd:
    dhcpcd.extraConfig = "nohook resolv.conf";
    # If using NetworkManager:
    networkmanager.dns = "none";
  };

  services.unbound.enable = true;
  services.unbound.settings.server.interface = [ "0.0.0.0" ];
  services.unbound.settings.server.access-control = [ "192.168.0.0/24 allow" "127.0.0.0/8 allow" "10.100.0.0/8 allow"];
  services.unbound.settings.forward-zone = [{
    name = ".";
    forward-addr = [ "127.0.0.1@43" ];
  }];
  services.unbound.settings.server.do-not-query-localhost = false;
  services.unbound.settings.server.local-zone = "\"ganier.fr\" transparent"; 
  services.unbound.settings.server.local-data = [ 
    "\"traefik.ganier.fr. 86400 IN A 192.168.0.254\""
    "\"hass.ganier.fr. 86400 IN A 192.168.0.254\""
    "\"photoprism.ganier.fr. 86400 IN A 192.168.0.254\"" 
    "\"syncthing.ganier.fr. 86400 IN A 192.168.0.254\"" 
  ];

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      listen_addresses = ["0.0.0.0:43"];
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      server_names = [ "cloudflare" "scaleway-fr" "scaleway-ams" ];
    };
  };

}
