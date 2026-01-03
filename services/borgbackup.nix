{ config, pkgs, ... }:

{
  services.borgbackup.jobs = {
    nas_backup = {
      paths = [
        "/mnt/secrets"
	"/var/lib/syncthing/marie"
	"/var/lib/syncthing/cyril"
	"/var/lib/syncthing/cyril-photos"
	"/var/lib/hass"
      ];
      repo = "u339464@u339464.your-storagebox.de:nas_backup";
      environment = { BORG_RSH = "ssh -p23 -i /mnt/secrets/hetzner_ssh_key"; };
      encryption = {
	mode = "repokey-blake2";
	passCommand = "cat /mnt/secrets/borgbackup_nixos_encryption_pass";
      };
      startAt = "weekly";

    };
  };
}
