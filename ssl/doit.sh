openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes  -keyout ssl-cert.key -days 3560 -out ssl-cert.pem \
 -subj "/CN=glip.gpa.com" -addext "subjectAltName=DNS:gpa.com,DNS:www.example.net,IP:10.0.0.1" 
chown www-data:www-data ssl-cert.key ssl-cert.pem
