{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # Define on which hard drive you want to install Grub.
  # We are not running UEFI firmware on the virtual machine.
  boot.loader.grub.device = "/dev/vda"; # use "nodev" for EFI-only mode

  # If your boot mode is UEFI, uncomment the following.
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.efiSupport = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "otanix-server"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  time.timeZone = "Europe/Helsinki";
  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTEXhQHAnlI2MfD26A9QL1hkLnalR4RI7TAiDL2CuMG" # id_rsa_otanix_server
  ];

  system.stateVersion = "25.05";
}
