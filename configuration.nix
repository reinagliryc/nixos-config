{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./services/zfs.nix
      ./services/traefik.nix
      ./services/syncthing.nix
      ./services/dnscrypt-proxy.nix
      ./services/photoprism.nix
      ./services/home-assistant.nix
      ./services/wireguard.nix      
    ];

  nix.settings.trusted-users = [ "root" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # ATI video card

  #boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "amd_iommu=pt" "ivrs_ioapic[32]=00:14.0" "iommu=soft" ];
  services.xserver.videoDrivers = [ "dummy" ];
  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.enable = true;
  #hardware.opengl.driSupport = true;

  networking = { 
    hostName = "nixos";
    hostId = "3b814a1e";  
    useDHCP = false;
    interfaces."enp37s0" = {
      useDHCP=true;
    };
    defaultGateway = "192.168.0.1";
    nameservers = [ "127.0.0.1" "8.8.8.8" ];
  };
 

  console.font = "ter-v32n";
  console.packages = with pkgs; [ terminus_font ];
  console.keyMap = "us";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Paris";

  environment.systemPackages = with pkgs; [
    (neovim.override {
      viAlias = true;
      vimAlias = true;
    })
    git
    htop
    lm_sensors
    iperf
    usbutils
    zellij
    claude-code
  ];

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      53 80 443 # traefik
      5900
    ];
    allowedUDPPorts = [ 
      53
    ];
  };

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.package = pkgs.zfs_unstable;

  users.users.cyril = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6Bk4diVZNlBlgMs4Vg/Cu+WWI2mqszVnfYXBzuU9yTvcFJMDeUPO5TiVtpSFViDwSHirABjvBRESCFF7Tbc9XhrIYKx2gGWrKRwdAd2+xdrbG/j5Tk70e/7NERnweys3AlVgNMrfVTsC4PKiWnP/Q9et8FNfyuiLsdGMZbYf28/tzfJS89pnBlqkgqDDOevRFkNLm9P59KQSBzUgzjkswjEV1JpV2Ywy3mrzdgCD3LTrQiooPDqeXidc+I0zNgko69l5n/wBJSCVj/L1l1B7xW8jodmuay0/H1JVls6UoJt1mCbKfQQ61doVvOt3s6SV56/yjNPQWXh9xKgyUo3IGgzQT5ZMff6v8la88mfpWmNVXqBVO5hWbvEm576ZDLbBa9ZZMnLMcH5kNw5ZCNLTiP91nRJR1T8W/BfktyqBosCCQRNHPcXIeEuHfhX6A3OP7Mhzpkb4bZWm9Ruon7tn0YJ7S5gJ1aBQP7lFpxc9knN/OusH7ZPctsV0xtadPBzp1JwznvRS1j/0jkYAyAhXAiDJCqKjjvHjqYwEquJC6WuGUrM6sL5CrsZ6Z7VOhcIJELm8A4jpceiFKdevTaVwx6cEnhlAcOfiBOtcGspB/5ltKWJ4s8ejm+khOGNkcPXIMdbihZe8uWcbz4mjHu3TFIxMjFOOhw7XQ3MysqDwU0Q== cardno:10_625_810"
    ];
  };
  
  security.sudo.wheelNeedsPassword = false;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  system.stateVersion = "22.05";
}

