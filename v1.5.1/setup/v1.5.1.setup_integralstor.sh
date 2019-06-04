#!/bin/bash

nrpm_path="http://192.168.1.150/netboot/distros/centos/7.4/x86_64/integralstor/v1.5.1/non-rpms"
docker_images="http://192.168.1.150/netboot/distros/centos/7.4/x86_64/integralstor/v1.5.1/docker"

# Configure network interfaces
echo "Configure network interfaces"
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-eno*
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-enp*
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-em*
sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i 's/ONBOOT=yes/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-eno*
sed -i 's/ONBOOT=yes/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-enp*
sed -i 's/ONBOOT=yes/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-em*
sed -i 's/ONBOOT=yes/ONBOOT=no/' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i 's/NM_CONTROLLED=no/NM_CONTROLLED=yes/' /etc/sysconfig/network-scripts/ifcfg-eno*
sed -i 's/NM_CONTROLLED=no/NM_CONTROLLED=yes/' /etc/sysconfig/network-scripts/ifcfg-enp*
sed -i 's/NM_CONTROLLED=no/NM_CONTROLLED=yes/' /etc/sysconfig/network-scripts/ifcfg-em*
sed -i 's/NM_CONTROLLED=no/NM_CONTROLLED=yes/' /etc/sysconfig/network-scripts/ifcfg-eth*
sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-eno*
sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-enp*
sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-em*
sed -i 's/IPV6INIT=yes/IPV6INIT=no/' /etc/sysconfig/network-scripts/ifcfg-eth*


# Prevent Network Manager from adding DNS servers received from DHCP to /etc/resolv.conf
echo "Prevent Network Manager from adding DNS servers received from DHCP to /etc/resolv.conf"
sed -i '/\[main\]/a dns=none' /etc/NetworkManager/NetworkManager.conf
echo "NETWORKING=yes" >> /etc/sysconfig/network
echo "127.0.0.1   localhost   localhost.localdomain   localhost4    localhost4.localdomain4" > /etc/hosts


# Disable OPenGPGCheck
echo "Disable OPenGPGCheck"
if [ -e "/etc/abrt/abrt-action-save-package-data.conf" ] ; then
  sed -i 's/OpenGPGCheck = yes/OpenGPGCheck = no/' /etc/abrt/abrt-action-save-package-data.conf
else
  echo "No such file found : /etc/abrt/abrt-action-save-package-data.conf"
fi


# Configure sshd
echo "Configure sshd"
/usr/sbin/sshd stop
cp /etc/ssh/sshd_config /etc/ssh/original_sshd_config
sed '/#PermitRootLogin/a PermitRootLogin no' /etc/ssh/sshd_config > /etc/ssh/temp_file
rm -f /etc/ssh/sshd_config
mv /etc/ssh/temp_file /etc/ssh/sshd_config
/usr/sbin/sshd start


# Disable CentOS base, updates and extras repositories
echo "Disable CentOS base, updates and extras repositories"
cp -rf /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/Original-CentOS-Base-repo
sed -i '/\[base\]/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[updates\]/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[extras\]/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[centosplus\]/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
sed -i '/\[contrib\]/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo


# Create required directories
echo "Create required directories"
/usr/bin/mkdir -p /opt/integralstor
/usr/bin/mkdir -p /run/samba


# Pull and extract Integralstor tar ball
echo "Pull and extract Integralstor tar ball"
cd /opt/integralstor/
/usr/bin/wget -c "$nrpm_path/integralstor.tar.gz"
/bin/tar xzf integralstor.tar.gz
rm integralstor.tar.gz

# Pull and install non RPM packages
echo "Pull and install non RPM packages"
cd /tmp
/usr/bin/wget -c "$nrpm_path/sysstat-11.0.5.tar.xz"
/bin/tar xJf sysstat-11.0.5.tar.xz
cd sysstat-11.0.5
./configure --prefix=/usr
make
make install
rm -rf sysstat-11.0.5*
cd /tmp
/usr/bin/wget -c "$nrpm_path/setuptools-29.0.1.tar.gz"
/bin/tar xzf setuptools-29.0.1.tar.gz
cd setuptools-29.0.1
python setup.py install
rm -rf setuptools-29.0.1*

cd /tmp
/usr/bin/wget -c "$nrpm_path/uwsgi-2.0.9.tar.gz"
/bin/tar xzf uwsgi-2.0.9.tar.gz
cd uwsgi-2.0.9
python setup.py install
rm -rf uwsgi-2.0.9*

cd /tmp
/usr/bin/wget -c "$nrpm_path/netifaces-0.10.5.tar.gz"
/bin/tar xzf netifaces-0.10.5.tar.gz
cd netifaces-0.10.5
python setup.py install
rm -rf netifaces-0.10.5*

cd /tmp
/usr/bin/wget -c "$nrpm_path/six-1.10.0.tar.gz"
/bin/tar xzf six-1.10.0.tar.gz
cd six-1.10.0
python setup.py install
rm -rf six-1.10.0*

cd /tmp
/usr/bin/wget -c "$nrpm_path/python-dateutil-2.6.0.tar.gz"
/bin/tar xzf python-dateutil-2.6.0.tar.gz
cd python-dateutil-2.6.0
python setup.py install
rm -rf python-dateutil-2.6.0*

cd /tmp
/usr/bin/wget -c "$nrpm_path/python-crontab-2.1.1.tar.gz"
/bin/tar xzf python-crontab-2.1.1.tar.gz
cd python-crontab-2.1.1
python setup.py install
cd /tmp
rm -rf python-crontab-2.1.1*

cd /tmp
/usr/bin/wget -c "$nrpm_path/mbuffer-20161115.tgz"
/bin/tar xzf mbuffer-20161115.tgz
cd mbuffer-20161115
./configure
make && make install
cd /tmp
rm -rf mbuffer-20161115*

cd /tmp
/usr/bin/wget -c "$nrpm_path/zfs-auto-snapshot.tar.gz"
/bin/tar xzf zfs-auto-snapshot.tar.gz
cd zfs-auto-snapshot
make install
cd /tmp
rm -rf zfs-auto-snapshot*

cd /tmp
/usr/bin/wget -c "$nrpm_path/Django-1.8.16.tar.gz"
/bin/tar xzf Django-1.8.16.tar.gz
cd Django-1.8.16
python setup.py install
cd /tmp
rm -rf Django-1.8.16*

cd /tmp
/usr/bin/wget -c "$nrpm_path/cron_descriptor-1.2.6.tar.gz"
/bin/tar xzf cron_descriptor-1.2.6.tar.gz
cd cron_descriptor-1.2.6
python setup.py install
cd /tmp
rm -rf cron_descriptor-1.2.6*

cd /tmp
/usr/bin/wget -c "$nrpm_path/reportlab.tar.gz"
/bin/tar xzf reportlab.tar.gz
cd reportlab
pip install --no-index --find-links="/tmp/reportlab/" reportlab
cd /tmp
rm -rf reportlab*


cd /tmp
/usr/bin/wget -c "$nrpm_path/nagios-plugins-2.1.4.tar.gz"
/bin/tar -xvf nagios-plugins-2.1.4.tar.gz
cd nagios-plugins-2.1.4
./configure
make
make install
cd /tmp
rm -rf nagios-plugins-2.1.4*
cd /tmp
/usr/bin/wget -c "$nrpm_path/nrpe-3.0.1.tar.gz"
/bin/tar -xvf nrpe-3.0.1.tar.gz
cd nrpe-3.0.1/
./configure
make all
make install-groups-users
make install
make install-plugin
make install-daemon
make install-config
make install-init
cd /tmp
rm -rf nrpe*
rm -rf nrpe-3.0.1*

modprobe ipmi_devintf
modprobe 8021q

hardware_vendor=''
hardware_vendor=`cat /root/hardware_vendor | cut -d':' -f2`
# Configure Integralstor
echo "Configure Integralstor"
echo "Hardware vendor: $hardware_vendor"
echo "/opt/integralstor/integralstor/install/configure_integralstor.sh $hardware_vendor" | /bin/bash

if grep "dell" /opt/integralstor/platform > /dev/null
then
  (crontab -l 2>/dev/null; echo "@reboot srvadmin-services.sh restart > /tmp/srvadmin_logs >> /tmp/srvadmin_errors") | crontab -
  echo "copying integralstor repository..."
  cd /etc/yum.repos.d
  /usr/bin/wget -c http://192.168.1.150/netboot/distros/centos/7.4/x86_64/integralstor/v1.5.1/integralstor.repo
  echo "copying integralstor repository...Done"
  echo "installing dell specific dependencies..."
  yum install srvadmin-all dell-system-update -y
  echo "installing dell specific dependencies...Done"
  echo "disabling integralstor repository..."
  sed -i '/\[updates\]/a enabled=0' /etc/yum.repos.d/integralstor.repo
  echo "disabling integralstor repository...Done"
else
  echo "Non dell hardware."
fi

# Run login_menu.sh at user login
echo "Run login_menu.sh at user login"
ln -s /opt/integralstor/integralstor/scripts/shell/login_menu.sh /etc/profile.d/spring_up.sh

# Configuring nagios
echo "Configuring nagios"
echo "nrpe            5666/tcp                 NRPE" >>/etc/services
iptables -A INPUT -p tcp -m tcp --dport 5666 -j ACCEPT
firewall-cmd --zone=public --add-port=5666/tcp --permanent

# Copy verify script 
/usr/bin/wget -c "$nrpm_path/verify_integralstor.sh" -P /opt/integralstor/integralstor/install/scripts/

echo "Configuring Integralstor updates repository..."
mkdir /tmp/integralstor_updates_repo && cd /tmp/integralstor_updates_repo
/usr/bin/wget -c "$nrpm_path/integralstor_updates_repo.tar.gz"
/bin/tar xzf integralstor_updates_repo.tar.gz

cat > /etc/yum.repos.d/integralstor_repo.repo << EOF
[integralstor_repo]
enabled=1
name= Integralstor - Updates
baseurl=file:///tmp/integralstor_updates_repo/integralstor_updates_repo
gpgcheck=0
EOF

# Install ledmon, Netdata dependencies and Docker CE
echo "Installing Netdata..."
echo "Installing Docker CE..."
yum install autoconf automake curl gcc git libmnl-devel libuuid-devel lm_sensors make MySQL-python nc pkgconfig python python-psycopg2 PyYAML zlib-devel docker-ce urbackup-server ledmon -y
echo "Configuring docker apps.."
systemctl start docker
mkdir /tmp/docker_images && cd /tmp/docker_images
/usr/bin/wget -c "$docker_images/nextcloud.tar.gz"
/usr/bin/gzip -d nextcloud.tar.gz
docker load < nextcloud.tar
rm -rf nextcloud.tar
/usr/bin/wget -c "$docker_images/onlyoffice_document_server.tar.gz"
/usr/bin/gzip -d onlyoffice_document_server.tar.gz
docker load < onlyoffice_document_server.tar
rm -rf onlyoffice_document_server.tar

# Install miscellaneous tools needed by admins
echo "Installing miscellaneous packages"
yum install fio libaio libaio-devel screen bind-utils net-tools screen cifs-utils autofs nss-pam-ldapd openldap-clients stress unzip tcpdump nmap -y 

# Install and configure Kimchi
yum install -y libvirt-python libvirt libvirt-daemon-config-network qemu-kvm python-ethtool sos \
python-ipaddr nfs-utils iscsi-initiator-utils pyparted python-libguestfs libguestfs-tools novnc \
spice-html5 python-configobj python-magic python-paramiko python-pillow virt-top
yum install wok -y
yum install kimchi -y
systemctl enable wokd
cp /etc/nginx/conf.d/wok.conf /etc/nginx/sites-enabled

# Configure AFP repo
rm -rf /etc/yum.repos.d/integralstor_repo.repo
mkdir /tmp/afp_repo && cd /tmp/afp_repo
/usr/bin/wget -c "$nrpm_path/afp_repo.tar.gz"
/bin/tar xzf afp_repo.tar.gz

cat > /etc/yum.repos.d/afp_repo.repo << EOF
[afp_repo]
enabled=1
name= Integralstor - Updates
baseurl=file:///tmp/afp_repo/afp_repo
gpgcheck=0
EOF

# Installing AFP
echo "Installing AFP..."
yum install avahi dbus nss-mdns gnome-boxes netatalk -y

mkdir -p /etc/avahi/services
mkdir -p /etc/netatalk
cp /opt/integralstor/integralstor/install/conf-files/services/afpd.service /etc/avahi/services/
cp /opt/integralstor/integralstor/install/conf-files/services/afpd.conf /etc/netatalk/
echo "hosts: files mdns4_minimal dns mdns mdns4" >> /etc/nsswitch.conf
rm -rf /etc/yum.repos.d/afp_repo.repo


mkdir /tmp/netdata && cd /tmp/netdata
/usr/bin/wget -c "$nrpm_path/netdata.tar.gz"
/usr/bin/tar xf netdata.tar.gz
cd netdata
/usr/bin/bash netdata-installer.sh --dont-wait --dont-start-it

# Log clean up script
cat > /etc/cron.daily/integralstor_cleanup_script << EOF
#!/bin/bash 

find /var/log/integralstor/archives/logs -type f -name '*.zip' -mtime +25 -exec rm {} \;
EOF
chmod +x /etc/cron.daily/integralstor_cleanup_script

# Turn on services
echo "Turn on services"
systemctl start nrpe &> /dev/null; systemctl enable nrpe &> /dev/null
systemctl start avahi-daemon &> /dev/null; systemctl enable avahi-daemon &> /dev/null
systemctl start netatalk &> /dev/null; systemctl enable netatalk &> /dev/null

# Remove old urbackup DB
rm -rf /var/urbackup/*

systemctl daemon-reload
udevadm control --reload-rules

sed -i 's/rhgb/net.ifnames=0 biosdevname=0 ipv6.disable=1/' /etc/default/grub &> /dev/null
grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null

# Configure default IP(172.16.16.16) on eth0
systemctl enable first-boot

