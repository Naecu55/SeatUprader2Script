#!/bin/bash
#####################################
#
# SeATV2 Upgrader Mysql Database Backup Script that it run from crontab -e once a Month
# Amended by Chuck on Thu May  4 06:01:08 BST 2017
#
####################################
LOGFILE=/var/log/seat_upgrade.log
echo "$(date) * SeAT Auto Upgrader"
echo
echo " * Be sure to read the source before continuing if you are unsure."
echo
echo 
echo " * Make a mysql backup, this can take awhile"
# Perform a mysqldump without a password prompt?
cd /home/camadi/mysql_backups/; sudo mysqldump -u root -p seat > seat$(date +"%Y%m%d").sql >>$LOGFILE
#cd /home/camadi/mysql_backups/; sudo mysqldump -u root --password="edew1gbb" seat > seat$(date +"%Y%m%d").sql
echo " * Mysql Backup of Database is now done"
echo " * Mysql Backup Status "
ls -ltr /home/camadi/mysql_backups/
echo " * Start SeATv2 Upgrader"
read -p "Are you sure you want to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
echo " * Starting the SeATv2 Upgrader"
#else
#  exit 0
#fi
# Debugging
set -e

echo " * Changing directories to /var/www/seat"
cd /var/www/seat
echo " * Putting SeAT into maintenance mode"php 
sudo php artisan down
echo " * Updating composer itself"
sudo /usr/local/bin/composer self-update
echo " * Updating SeAT packages"
sudo /usr/local/bin/composer update --no-dev 
echo " * Publishing vendor directories"
sudo php artisan vendor:publish --force
echo " * Running any database migrations"
sudo php artisan migrate
echo " * Running the schedule seeder"
sudo php artisan db:seed --class=Seat\\Services\\database\\seeds\\ScheduleSeeder
## echo " * Asking queue workers to restart"
## sudo php artisan queue:restart

echo " * Taking SeAT out of maintenance mode"
sudo php artisan up
echo " * Done "
echo " * Check whether the permissions are correct"
sudo  php artisan seat:admin:diagnose

else
echo " * OK, buddy, we will abort SeAT Auto Upgrader"
  exit 0
fi

