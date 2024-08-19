# monitoring

Actions items are marked with "ACTION:" inside the .conf files, you will need replace with correct values for your particular environment.

# Oracle Linux 9 (Python 3) migration

## Icinga scripts

On the cluster *mon host:
```
git clone git@github.com:ServicePattern/monitoring.git
cd monitoring/OL9_icinga
```

- Chrony
```
sudo mv check_chrony.py /usr/lib64/nagios/plugins/check_chrony.py
```
- MongoDB
```
sudo mv check_mongodb.py /usr/lib64/nagios/plugins/check_mongodb.py
```
- MariaDB Slave
```
sudo mv check_mysql_mariadb_slave.py /usr/lib64/nagios/plugins/sp/check_mysql_mariadb_slave.py
```
- SP service instances count
```
sudo mv icinga /etc/sudoers.d/icinga
sudo mv check_sp_service_instances_count.pl /usr/lib64/nagios/plugins/check_sp_service_instances_count.pl
```
