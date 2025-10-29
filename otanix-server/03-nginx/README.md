## Generating self-signed certificates

To generate a self-signed certificate, like the one in this directory, run `generate-selfsigned-certificate.sh`.
Edit the script to configure which host names and other options.

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

