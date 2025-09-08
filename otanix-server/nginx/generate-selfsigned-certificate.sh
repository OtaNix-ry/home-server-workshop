cat <<-EOF > /tmp/selfsignned-openssl.cnf
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
EOF

openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
        -keyout selfsigned.key -out selfsigned.pem \
        -config /tmp/selfsigned-openssl.cnf -extensions v3_req
