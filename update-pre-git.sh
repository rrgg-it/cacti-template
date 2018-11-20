#!/bin/bash

# bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/master/update-pre-git.sh)

if [[ `whoami` == "root" ]]; then
    echo "You ran me as root! Do not run me as root!"
    exit 1
    elif [[ `whoami` == "cacti" ]]; then
    echo ""
    else
    echo "Uh-oh. You are not logged in as the cacti user. Exiting..."
fi

# get the Cacti version
cactiver=$( cat /var/www/html/cacti/include/cacti_version )
upgrade_version=1.1.0
current_version=1.1.28

function version_gt() { 
test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

if version_gt $cactiver $upgrade_version; then
     echo "Installed cacti v$cactiver is greater than required v$upgrade_version! Proceeding to upgrade..."
elif version_gt $cactiver $current_version; then
	echo "Current installed Cacti v$cacti is current! No need to upgrade, exiting..."
else
	echo "Current cacti install v$cactiver is not compatible with upgrade version v$upgrade_version, exiting..."
	exit 1
fi

if [ -f ~/.cacti-template ]
then
	echo "Found preexisting Cacti-template v1.2.x Install, proceeding to upgrade..."
  bash <(curl -s https://raw.githubusercontent.com/KnoAll/cacti-template/master/update-git.sh)
  exit 1
else
	echo ""
fi

echo "Welcome to Kevin's Cacti Template upgrade script!"
echo ""

function upgrade-git () {
echo "Upgrading Git"
sudo rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm
sudo yum install -y git	
echo ""
}

function backup-db () {
echo "Backing up DB..."
mysqldump --user=cacti --password=cacti -l --add-drop-table cacti |gzip > /var/www/html/cacti/mysql.cacti_$(date +\%Y\%m\%d).sql.gz
echo ""
}

function upgrade-cacti () {
echo "Begining Cacti upgrade..."
cd /var/www/html/
mv cacti/ cacti_$cactiver/
git clone -b master https://github.com/cacti/cacti.git --single-branch
cp -u -R cacti_$cactiver/scripts/* cacti/scripts/
cp -u -R cacti_$cactiver/resource/* cacti/resource/
update-config
update-permissions
echo ""
}

function upgrade-plugins () {
echo "Upgrading plugins..."
cd /var/www/html/
echo "Upgrading Mactrack..."
git clone https://github.com/Cacti/plugin_mactrack.git cacti/plugins/mactrack
echo ""
echo "Upgrading Monitor..."
git clone https://github.com/Cacti/plugin_monitor.git cacti/plugins/monitor
echo ""
echo "Upgrading Webseer..."
git clone https://github.com/Cacti/plugin_webseer.git cacti/plugins/webseer
echo ""
echo "Upgrading GExport..."
git clone https://github.com/Cacti/plugin_gexport.git cacti/plugins/gexport
echo ""
echo "Upgrading Syslog..."
git clone https://github.com/Cacti/plugin_syslog.git cacti/plugins/syslog
echo "Updating syslog config..."
update-syslog-config
echo ""
echo "Upgrading THold..."
git clone https://github.com/Cacti/plugin_thold.git cacti/plugins/thold
echo ""
echo "Upgrading Routerconfigs..."
git clone https://github.com/Cacti/plugin_routerconfigs.git cacti/plugins/routerconfigs
echo ""
echo "Upgrading FlowView..."
git clone https://github.com/Cacti/plugin_flowview.git cacti/plugins/flowview
echo ""
echo "Upgrading Maint..."
git clone https://github.com/Cacti/plugin_maint.git cacti/plugins/maint
echo ""
echo "Upgrading Audit..."
git clone https://github.com/Cacti/plugin_audit.git cacti/plugins/audit
echo ""
echo "Upgrading Cycle..."
git clone https://github.com/Cacti/plugin_cycle.git cacti/plugins/cycle
echo ""
#echo "Upgrading Weathermap..."
#git clone https://github.com/howardjones/network-weathermap.git --single-branch cacti/plugins/weathermap
#echo ""
#echo "Installing Weathermap..."
#cd cacti/plugins/weathermap/
#bower install --allow-root
#composer update --no-dev
#echo ""
}

function update-config () {
echo "Updating cacti config..."
cd /var/www/html/
cp cacti/include/config.php.dist cacti/include/config.php
echo "$(awk '{sub(/cactiuser/,"cacti")}1' cacti/include/config.php)" > cacti/include/config.php
}

function update-syslog-config () {
echo "Updating syslog plugin config..."
cd /var/www/html/
cp cacti/plugins/syslog/config.php.dist cacti/plugins/syslog/config.php
echo "$(awk '{sub(/cactiuser/,"cacti")}1' cacti/plugins/syslog/config.php)" > cacti/plugins/syslog/config.php
}

function update-permissions () {
touch /var/www/html/cacti/log/cacti.log
sudo chgrp -R apache /var/www/html
sudo find /var/www/html -type d -exec chmod g+rx {} +
sudo find /var/www/html -type f -exec chmod g+r {} +
sudo chown -R cacti /var/www/html/
sudo find /var/www/html -type d -exec chmod u+rwx {} +
sudo find /var/www/html -type f -exec chmod u+rw {} +
sudo find /var/www/html -type d -exec chmod g+s {} +
chmod g+w cacti/log/cacti.log
}

function upgrade-spine () {
echo "Upgrading spine..."
echo ""
}

#upgrade-git
backup-db
upgrade-cacti
#upgrade-plugins
touch .cacti-template
echo "Everything done, exiting..."
exit 1
