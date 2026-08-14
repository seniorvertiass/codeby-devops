#!/bin/bash

set -e

DOMAIN="nosyrev.local"
WWW_DOMAIN="www.nosyrev.local"
SERVER_IP="192.168.56.10"

echo "=== Installing Apache and OpenSSL ==="

apt-get update
apt-get install -y apache2 openssl

echo "=== Enabling Apache modules ==="

a2enmod ssl
a2enmod rewrite
a2enmod headers

systemctl enable apache2
systemctl start apache2

echo "=== Creating website directory ==="

mkdir -p /var/www/$DOMAIN

cat > /var/www/$DOMAIN/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>$DOMAIN</title>
</head>
<body>
    <h1>HTTPS works!</h1>
    <p>Domain: $DOMAIN</p>
    <p>Server: $(hostname)</p>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/$DOMAIN

echo "=== Creating SSL certificate ==="

mkdir -p /etc/ssl/$DOMAIN

cat > /tmp/openssl-san.cnf << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[dn]
C = RU
ST = Moscow
L = Moscow
O = MyCompany
CN = ${DOMAIN}

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN}
DNS.2 = ${WWW_DOMAIN}
EOF


echo "=== Создание SSL сертификата с SAN для ${WWW_DOMAIN} ==="
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "/etc/ssl/${DOMAIN}.key" \
    -out "/etc/ssl/${DOMAIN}.crt" \
    -config /tmp/openssl-san.cnf \
    -extensions req_ext


if [ -f "/etc/ssl/${DOMAIN}.key" ] && [ -f "/etc/ssl/${DOMAIN}.crt" ]; then
    echo "Сертификаты созданы успешно"
    chmod 600 "/etc/ssl/${DOMAIN}.key"
    chmod 644 "/etc/ssl/${DOMAIN}.crt"
else
    echo "Ошибка: Сертификаты не созданы"
    exit 1
fi


echo "=== Configuring HTTP virtual host ==="

cat > /etc/apache2/sites-available/$DOMAIN.conf <<EOF
<VirtualHost *:80>

    ServerName $DOMAIN
    ServerAlias $WWW_DOMAIN

    RewriteEngine On

    RewriteRule ^ https://$DOMAIN%{REQUEST_URI} [R=301,L]

</VirtualHost>
EOF

echo "=== Configuring HTTPS virtual host ==="

cat > /etc/apache2/sites-available/$DOMAIN-ssl.conf <<EOF
<VirtualHost *:443>

    ServerName $DOMAIN
    ServerAlias $WWW_DOMAIN

    DocumentRoot /var/www/$DOMAIN

    SSLEngine on

    SSLCertificateFile /etc/ssl/$DOMAIN.crt
    SSLCertificateKeyFile /etc/ssl/$DOMAIN.key

    RewriteEngine On

    RewriteCond %{HTTP_HOST} ^www\.$DOMAIN$ [NC]
    RewriteRule ^ https://$DOMAIN%{REQUEST_URI} [R=301,L]

    <Directory /var/www/$DOMAIN>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined

</VirtualHost>
EOF

echo "=== Enabling site ==="

a2dissite 000-default.conf
a2ensite $DOMAIN.conf
a2ensite $DOMAIN-ssl.conf

apache2ctl configtest

systemctl restart apache2


mkdir -p /vagrant/certs
cp /etc/ssl/$DOMAIN.crt /vagrant/certs/

echo "=== SERVER provisioning completed ==="
