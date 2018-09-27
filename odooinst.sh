#!/bin/bash
#definir nuevo hostname de computador como odoo
sudo hostname odoo
#cambiar configuracion de /etc/hosts
#echo -e "127.0.0.1	localhost\n 127.0.1.1	odoo.yourdomain.com	odoo\n\n# The following lines are desirable for IPv6 capable hosts\n::1     ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" > /etc/hosts
#configura repositorios ubuntu server
echo -e "# \n# deb cdrom:[Ubuntu-Server 16.04.4 LTS _Xenial Xerus_ - Release amd64 (20180228)]/ xenial main restricted\n#deb cdrom:[Ubuntu-Server 16.04.4 LTS _Xenial Xerus_ - Release amd64 (20180228)]/ xenial main restricted\n# See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to\n# newer versions of the distribution.\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial main restricted\n## Major bug fix updates produced after the final release of the\n## distribution.\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted\n## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu\n## team. Also, please note that software in universe WILL NOT receive any\n## review or updates from the Ubuntu security team.\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial universe\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial universe\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe\n## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu \n## team, and may not be under a free licence. Please satisfy yourself as to \n## your rights to use the software. Also, please note that software in \n## multiverse WILL NOT receive any review or updates from the Ubuntu\n## security team.\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial multiverse\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial multiverse\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse\n## N.B. software from this repository may not have been tested as\n## extensively as that contained in the main release, although it includes\n## newer versions of some applications which may provide useful features.\n## Also, please note that software in backports WILL NOT receive any review\n## or updates from the Ubuntu security team.\ndeb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse\n# deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse\n## Uncomment the following two lines to add software from Canonical's \n## 'partner' repository.\n## This software is not part of Ubuntu, but is offered by Canonical and the\n## respective vendors as a service to Ubuntu users.\n# deb http://archive.canonical.com/ubuntu xenial partner\n# deb-src http://archive.canonical.com/ubuntu xenial partner\ndeb http://security.ubuntu.com/ubuntu xenial-security main restricted\n# deb-src http://security.ubuntu.com/ubuntu xenial-security main restricted\ndeb http://security.ubuntu.com/ubuntu xenial-security universe\n# deb-src http://security.ubuntu.com/ubuntu xenial-security universe\ndeb http://security.ubuntu.com/ubuntu xenial-security multiverse\n# deb-src http://security.ubuntu.com/ubuntu xenial-security multiverse" > texto.sh
#actualiza lista de paquetes desde repositorios
apt-get update && apt-get upgrade -y
#instala openssh-server y paquetes necesarios antes de iniciar
apt-get install openssh-server software-properties-common -y
#agregar el repositorio oficial del PostgreSQL-Xenial
sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
# importar llaves del repositorio
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
# actualizar el cache
apt update
#instalar el postgreSQL 9.6
apt install postgresql-9.6 postgresql-server-dev-9.6 -y
#crear usuario PostgreSQL
echo "Introduzca contraseña de usuario postgres"
sudo -u postgres createuser odoo -U postgres -dRSP
#parar el servicio de postgreSQL
sudo systemctl stop postgresql
#configurar la autenticacion basado en host
echo -e "host	all	odoo	odoo.yourdomain.com	md5" >> /etc/postgresql/9.6/main/pg_hba.conf
#Crear un directorio para archivos WAL
sudo mkdir -p /var/lib/postgresql/9.6/main/archive/
#cambiar permisos del archivo
sudo chown postgres: -R /var/lib/postgresql/9.6/main/archive/
#habilitar PostgreSQL alinicio
sudo systemctl enable postgresql
#preparacion del odoo 11 creando usuario
sudo adduser --system --home=/opt/odoo --group odoo
#configurar logs
sudo mkdir /var/log/odoo
#Instalando odoo 11
sudo apt install git -y
#usar git para clonar los archivos de odoo
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 11.0 --single-branch /opt/odoo
export LC_ALL=C
#instalar nuevas dependencias de python
sudo apt-get install python3 python3-pip python3-suds python3-all-dev python3-dev python3-setuptools python3-tk -y
#instalar dependencias globales de odoo
sudo apt install git libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev pkg-config libtiff5-dev libjpeg8-dev libjpeg-dev zlib1g-dev libfreetype6-dev liblcms2-dev liblcms2-utils libwebp-dev tcl8.6-dev tk8.6-dev libyaml-dev fontconfig -y
#instalar codigos especificos de python
sudo -H pip3 install --upgrade pip
sudo -H pip3 install -r /opt/odoo/doc/requirements.txt
sudo -H pip3 install -r /opt/odoo/requirements.txt
#instalacion de less por node js
sudo curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && sudo apt-get install -y nodejs && sudo npm install -g less less-plugin-clean-css
cd /tmp
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
tar -xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
apt-get install node-less -y
sudo mv wkhtmltox/bin/wk* /usr/bin/ && sudo chmod a+x /usr/bin/wk*
#renombrar archivo de configuraciones del servidor
sudo cp /opt/odoo/debian/odoo.conf /etc/odoo-server.conf
#modificar el archivo de configuraciones
echo -e "[options]\nadmin_passwd = admin\ndb_host = odoo.yourdomain.com\ndb_port = False\ndb_user = odoo\ndb_password = odoo_password\naddons_path = /opt/odoo/addons\nlogfile = /var/log/odoo/odoo-server.log\nxmlrpc_port = 8070" > /etc/odoo-server.conf
#crear el servicio de odoo
touch /lib/systemd/system/odoo-server.service
echo -e "[Unit]\nDescription=Odoo Open Source ERP and CRM\n\n[Service]\nType=simple\nPermissionsStartOnly=true\nSyslogIdentifier=odoo-server\nUser=odoo\nGroup=odoo\nExecStart=/opt/odoo/odoo-bin --config=/etc/odoo-server.conf --addons-path=/opt/odoo/addons/\nWorkingDirectory=/opt/odoo/\n\n[Install]\nWantedBy=multi-user.target" > /lib/systemd/system/odoo-server.service
# cambiar permisos de propietarios
sudo chmod 755 /lib/systemd/system/odoo-server.service && sudo chown root: /lib/systemd/system/odoo-server.service
sudo chown -R odoo: /opt/odoo/
sudo chown odoo:root /var/log/odoo
sudo chown odoo: /etc/odoo-server.conf && sudo chmod 640 /etc/odoo-server.conf
sudo systemctl start odoo-server
#habilita el servicio de odoo
sudo systemctl enable odoo-server
