apt-get install git
apt install software-properties-common
apt-get install adduser sudo aptitude
add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
aptitude install libssl1.0.0
aptitude install postgresql-9.6 postgresql-server-dev-9.6
echo "Type postgres 'odoo' user password"
sudo -u postgres createuser odoo -U postgres -dRSP
sudo systemctl stop postgresql
echo -e "host	all	odoo	odoo.yourdomain.com	md5" >> /etc/postgresql/9.6/main/pg_hba.conf
sudo systemctl start postgresql
sudo systemctl enable postgresql
adduser --system --home=/opt/odoo --group odoo
mkdir /var/log/odoo
git clone https://www.github.com/odoo/odoo --depth 1 --branch 11.0 --single-branch /opt/odoo
export LC_ALL=C
sudo apt-get install python3 python3-pip python3-suds python3-all-dev python3-dev python3-setuptools python3-tk
sudo apt install git libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev pkg-config libtiff5-dev libjpeg62-turbo-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev liblcms2-utils libwebp-dev tcl8.6-dev tk8.6-dev libyaml-dev fontconfig
sudo -H pip3 install --upgrade pip
sudo -H pip3 install -r /opt/odoo/doc/requirements.txt
sudo -H pip3 install -r /opt/odoo/requirements.txt
apt-get install curl
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g less less-plugin-clean-css
cd /tmp
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
sudo mv wkhtmltox/bin/wk* /usr/bin/ && sudo chmod a+x /usr/bin/wk*
sudo cp /opt/odoo/debian/odoo.conf /etc/odoo-server.conf
echo -e "[options]\admin_passwd = admin\db_host = masterdb.yourdomain.com\db_port = False\db_user = odoo\db_password = odoo_password\addons_path = /opt/odoo/addons\logfile = /var/log/odoo/odoo-server.log\xmlrpc_port = 8070" > /etc/odoo-server.conf
touch /lib/systemd/system/odoo-server.service
echo -e "[Unit]\Description=Odoo Open Source ERP and CRM\[Service]\Type=simple\PermissionsStartOnly=true\SyslogIdentifier=odoo-server\User=odoo\Group=odoo\ExecStart=/opt/odoo/odoo-bin --config=/etc/odoo-server.conf --addons-path=/opt/odoo/addons/\WorkingDirectory=/opt/odoo/\[Install]\WantedBy=multi-user.target" > /lib/systemd/system/odoo-server.service
sudo chmod 755 /lib/systemd/system/odoo-server.service && sudo chown root: /lib/systemd/system/odoo-server.service
sudo chown -R odoo: /opt/odoo/
sudo chown odoo:root /var/log/odoo
sudo chown odoo: /etc/odoo-server.conf && sudo chmod 640 /etc/odoo-server.conf
sudo systemctl start odoo-server
sudo systemctl status odoo-server
sudo apt-get install nginx
sudo touch /etc/nginx/sites-available/odoo
echo -e "## Odoo Backend ## \upstream odooerp { \server 127.0.0.1:8069;\}\## https site##\server {\listen 443 default_server; \server_name odoo.mysite.co;\root /usr/share/nginx/html;\index index.html index.htm;\# log files\access_log /var/log/nginx/odoo.access.log;\error_log /var/log/nginx/odoo.error.log;\# ssl filess\ssl on;\ssl_ciphers ALL:!ADH:!MD5:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM;\ssl_protocols TLSv1 TLSv1.1 TLSv1.2;\ssl_prefer_server_ciphers on;\ssl_certificate /etc/nginx/ssl/odoo.crt;\ssl_certificate_key /etc/nginx/ssl/odoo.key;\# proxy buffers\proxy_buffers 16 64k;\proxy_buffer_size 128k;\## odoo proxypass with https\## location / {\proxy_pass http://odooerp; \# force timeouts if the backend dies\proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;\proxy_redirect off;\# set headers\proxy_set_header Host $host;\proxy_set_header X-Real-IP $remote_addr;\proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\proxy_set_header X-Forwarded-Proto https;\} \# cache some static data in memory for 60mins\location ~* /web/static/ {\proxy_cache_valid 200 60m;\proxy_buffering on;\expires 864000;\proxy_pass http://odooerp; \}\}\## http redirects to https ##\server {\listen 80;\server_name odoo.mysite.co;\# Strict Transport Security\add_header Strict-Transport-Security max-age=2592000;\rewrite ^/.*$ http://odooerp; permanent;\}" > /etc/nginx/sites-available/odoo
ln -s /etc/nginx/sites/available/odoo /etc/nginx/sites-enabled/odoo
sudo mkdir -p /etc/nginx/ssl
echo "Please answer the questions for the ssl certification creation"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/odoo.key -out /etc/nginx/ssl/odoo.crt
sudo chmod 600 odoo.key
echo "Edit /etc/postgresql/9.6/main/postgresql.conf in From CONNECTIONS AND AUTHENTICATION Section: listen_addresses = '*'"
echo "Change the db_password field with the PostgreSQL odoo user password you created previously. The file is located at /etc/odoo-server.conf"
echo "By the moment the FQDN is considered to be odoo.yourdomain.com, if changed, change the /etc/postgresql/9.6/main/pg_hba.conf file and /etc/odoo-server.conf files"
