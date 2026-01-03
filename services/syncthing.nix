{ config, ... }:

{
  services.syncthing = {
    enable = true;
    dataDir = "/var/lib/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";
  };
}
