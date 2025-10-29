# 03: Web-based service hosting on NixOS: Nginx

At this point you can directly deploy [the configuration](./default.nix) by running

```
nixos-rebuild switch -A nixosConfigurations.otanix-server-03-nginx --target-host root@192.168.122.215
```

from the root of the repository, however you need to re-encrypt the secret file first so that your server's host key can decrypt it.

```
sops -i -d nginx-secrets.yaml
sops -i -e nginx-secrets.yaml
```

## Generating self-signed certificates

If you want, you can generate your own TLS certificates.

To generate a self-signed certificate, like the one in this directory, run the script `generate-selfsigned-certificate.sh`.
Edit the script to configure host names and other options.

> Note `10.127.0.1.nip.io` resolves to `10.127.0.1`, which is the ip address of the otanix-server wireguard interface.

## Modifying nginx-secrets.yaml

First, you need to export the age private key from the SSH key:

```
export SOPS_AGE_KEY=$(ssh-to-age -private-key < ../../id_rsa_otanix_server)
```

Then, edit the file:

```
sops nginx-secrets.yaml
```

And replace the `key` and the `cert` in the YAML.

Now you can deploy `nixosConfigurations.otanix-server-03-nginx` again.