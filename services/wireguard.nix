{ config, pkgs, ... }:

{

# enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "enp37s0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp37s0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o enp37s0 -j MASQUERADE
      '';

      privateKeyFile = "/var/lib/wireguard-keys/private";
      generatePrivateKeyFile = true;
      peers = [
        { 
          publicKey = "vf0862eYODAfNDctZhkVsTgw7q9BJLumbQPUNSNxvkw=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
	{
	  publicKey = "oNgzhxeGneqHV5uoKwKoNpd63btnbBV+qm6Um5DkxlI=";
	  allowedIPs = [ "10.100.0.3/32" ];
	}
      ];
    };
  };

}
