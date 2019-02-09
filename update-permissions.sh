#!/bin/bash

echo -e "\033[32m Updating Apache permissions"
echo -e -n "\033[0m"
if [[ $os_dist == "raspbian" ]]; then
	sudo chown -R www-data:www-data /var/www/html/
	if [ $? -ne 0 ];then
		echo -e "\033[31m Something went updating permissions, exiting..."
		echo -e -n "\033[0m"
		exit 1
	else
		sudo chmod -R g+w /var/www/html/
			if [ $? -ne 0 ];then
				echo -e "\033[31m Something went updating permissions, exiting..."
				echo -e -n "\033[0m"
				exit 1
			else
				sudo find /var/www/html -type d -exec chmod g+rwx {} +
				sudo find /var/www/html -type f -exec chmod g+rw {} +
				sudo find /var/www/html -type d -exec chmod u+rwx {} +
				sudo find /var/www/html -type f -exec chmod u+rw {} +
				sudo find /var/www/html -type d -exec chmod g+s {} +
				#sudo find /var/www/html -type f -exec chmod g+s {} +
			fi	
	fi
elif [[ $os_dist == "centos" ]]; then
	sudo chown -R cacti:apache /var/www/html/
	if [ $? -ne 0 ];then
		echo -e "\033[31m Something went updating permissions, exiting..."
		echo -e -n "\033[0m"
		exit 1
	else
		sudo chmod -R g+w /var/www/html/
			if [ $? -ne 0 ];then
				echo -e "\033[31m Something went updating permissions, exiting..."
				echo -e -n "\033[0m"
				exit 1
			else
				sudo find /var/www/html -type d -exec chmod g+rwx {} +
				sudo find /var/www/html -type f -exec chmod g+rw {} +
				sudo find /var/www/html -type d -exec chmod u+rwx {} +
				sudo find /var/www/html -type f -exec chmod u+rw {} +
				sudo find /var/www/html -type d -exec chmod g+s {} +
				#sudo find /var/www/html -type f -exec chmod g+s {} +
			fi	
	fi
fi
