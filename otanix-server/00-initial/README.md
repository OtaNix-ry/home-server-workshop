# Setting up a libvirt VM

Here are written instructions for installing NixOS on the VM.
See the [slides](https://github.com/OtaNix-ry/home-server-workshop/releases) for creating the VM with libvirt.

You should have a working SSH connection to the VM.

> If you have trouble starting the VM or connecting to it with SSH, see the [general troubleshooting in README](../../README.md#troubleshooting)

You should have this repository cloned on your host system at this stage.

Run all shell commands on the VM (through SSH), not on your host operating system.

## Disk partitioning with Disko

Write the contents of [`disko.nix`](./otanix-server/00-initial/disko.nix) to a file `disko.nix` using `nano` for instance.
Then run

```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount disko.nix
```

> Note: we assume that your boot mode is BIOS (legacy).
> If your hypervisor uses UEFI boot, you need to comment the `boot` section in `disko.nix` and uncomment the `ESP` section.
> Also change the configuration (`default.nix`) to use the EFI boot loader.
> See [the official manual](https://nixos.org/manual/nixos/stable/#sec-installation-manual-installing) for more information.

## NixOS installation

1. Generate the configuration

    ```
    sudo nixos-generate-config --root /mnt
    ```

2. Copy `/mnt/etc/nixos/hardware-configuration.nix` from the VM to this directory as it contains a random filesystem UUID

    ```
    cat /mnt/etc/nixos/hardware-configuration.nix
    ```

3. Replace the generated `/mnt/etc/nixos/configuration.nix` on the server with the configuration from this repository

    ```
    sudo rm /mnt/etc/nixos/configuration.nix
    sudo nano /mnt/etc/nixos/configuration.nix
    ```
    
    Paste [this configuration](./default.nix) to the editor.

    > This example uses the SSH key found at the [root of the repository](/id_rsa_otanix_server).

4. Run the installer and provide a root password

    ```
    sudo nixos-install
    ```

5. Reboot into the new system with `sudo reboot` and check the virt-manager graphical console to ensure that it has booted into the new system. It should show "otanix-server login".

## SSH to the new installation

Because to the installer's [SSH host key](https://www.ssh.com/academy/ssh/host-key) was not copied to the virtual disk, our host machine's SSH client will complain about _SSH host key verification_, which you solve by checking the [troubleshooting guide](../../README.md#troubleshooting).

```
chmod 600 id_rsa_otanix_server
ssh-keygen -R 192.168.122.215
ssh root@192.168.122.215 -i id_rsa_otanix_server
```

> Replace the IP address 192.168.122.215 with your server's address. You should replace it in all the upcoming commands as well.