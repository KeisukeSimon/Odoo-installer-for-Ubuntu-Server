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
echo "Edit /etc/postgresql/9.6/main/postgresql.conf in From CONNECTIONS AND AUTHENTICATION Section: listen_addresses = '*'"
echo "Change the db_password field with the PostgreSQL odoo user password you created previously. The file is located at /etc/odoo-server.conf"
echo "By the moment the FQDN is considered to be odoo.yourdomain.com, if changed, change the /etc/postgresql/9.6/main/pg_hba.conf file and /etc/odoo-server.conf files"
