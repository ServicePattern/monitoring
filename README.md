# monitoring

Actions items are marked with "ACTION:" inside the .conf files, you will need replace with correct values for your particular environment.

# Oracle Linux 9 (Python 3) migration

On the Icinga master node (icinga.brightpattern.com):
```sh
sudo vim /etc/icinga2/zones.d/<cluster>/hosts.conf
```
replace all hosts IP `addresses` with `<host_fqdn>-int.brightpattern.com`

## Icinga scripts

On the cluster *mon OL9  host:
```sh
git clone git@github.com:ServicePattern/monitoring.git
cd monitoring/OL9_icinga
```

- Chrony
```sh
sudo mv check_chrony.py /usr/lib64/nagios/plugins/check_chrony.py
```
- MongoDB
```sh
sudo mv check_mongodb.py /usr/lib64/nagios/plugins/check_mongodb.py
```
- MariaDB Slave
```sh
sudo pip install PyMySQL
sudo mv check_mysql_mariadb_slave.py /usr/lib64/nagios/plugins/sp/check_mysql_mariadb_slave.py
```
- SP service instances count
```sh
sudo mv icinga /etc/sudoers.d/icinga
sudo mv check_sp_service_instances_count.pl /usr/lib64/nagios/plugins/check_sp_service_instances_count.pl
```

## Logarchive
```sh
cd ../OL9_archiving
```

- Logarchive
```sh
sudo mv logarchive.py /etc/archive/logarchive/logarchive.py
sudo mv coldstorage.py /etc/archive/logarchive/coldstorage.py
```

## Icinga installation from binary

[https://freedom-for-icinga.com/#install] (Original article)

```sh
sudo rpm --import https://packages.freedom-for-icinga.com/free-icinga.key
sudo curl https://packages.freedom-for-icinga.com/epel/FREE-ICINGA-release.repo -o /etc/yum.repos.d/FREE-ICINGA-release.repo
```
The packages depend on other packages which are distributed as part of the EPEL repository:
```sh
sudo dnf install epel-release
```

Install Icinga 2

```sh
sudo dnf install icinga2
systemctl enable icinga2
systemctl start icinga2
```

## How to build the latest Icinga RPM package for OL9 from source


