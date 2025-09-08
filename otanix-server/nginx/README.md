## Generating self-signed certificates

To generate a self-signed certificate, like the one in this directory, write to `/tmp/selfsigned-openssl.cnf`:

```
[ req ]
default_bits = 4096
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
CN = *.10.127.0.1.nip.io

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.10.127.0.1.nip.io
DNS.2 = 10.127.0.1.nip.io
```

> Note `10.127.0.1.nip.io` resolves to `10.127.0.1`, which is the ip address of the otanix-server wireguard interface.

and run

```
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
        -keyout selfsigned.key -out selfsigned.pem \
        -config /tmp/selfsigned-openssl.cnf -extensions v3_req
```

## Modifying nginx-secrets.yaml

First, you need to export the age private key from the SSH key:

```
export SOPS_AGE_KEY=$(ssh-to-age -private-key < ../../id_rsa_otanix_server)
```

Then, edit the file:

```
sops nginx-secrets.yaml
```

