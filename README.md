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

## Icinga installation from binary `(may not be the latest version)`
- Repo 1: [Original article](https://freedom-for-icinga.com/#install)

```sh
sudo rpm --import https://packages.freedom-for-icinga.com/free-icinga.key
sudo curl https://packages.freedom-for-icinga.com/epel/FREE-ICINGA-release.repo -o /etc/yum.repos.d/FREE-ICINGA-release.repo
```
The packages depend on other packages which are distributed as part of the EPEL repository:
```sh
sudo dnf install epel-release
```
- Repo 2: [Original article](https://copr.fedorainfracloud.org/coprs/jered/icinga2/)
```sh
sudo dnf copr enable jered/icinga2
```
- Repo 3: [Original article](https://copr.fedorainfracloud.org/coprs/relaix/utils/)
```sh
sudo dnf copr enable dnf copr enable relaix/utils
```

Install Icinga 2

```sh
sudo dnf install icinga2
systemctl enable icinga2
systemctl start icinga2
```

## How to build the `2.14.2` Icinga RPM package for OL9 from source

[Original article](https://freedom-for-icinga.com/#build)

In order to build RPM packages for the latest version of Icinga, we need 2 files:

- Archive with Icinga source files: v2.14.2.tar.gz [download from Icinga github](https://github.com/Icinga/icinga2/archive/refs/tags/v2.14.2.tar.gz)
- icinga2.spec [download from copr.fedorainfracloud.org](https://download.copr.fedorainfracloud.org/results/jered/icinga2/epel-9-x86_64/07227811-icinga2/icinga2.spec)

Build:

Install some required packages
```sh
sudo dnf -y install git-core mock
```
Add the current user to the mock group
```sh
sudo usermod -a -G mock $USER
```
Logout the system and log back in

Download the desired version release
```sh
curl -LO https://github.com/Icinga/icinga2/archive/refs/tags/v2.14.2.tar.gz
```
And the corresponding specification file (or locally in OL9_icinga/v2.14.2/)
```sh
curl -LO https://download.copr.fedorainfracloud.org/results/jered/icinga2/epel-9-x86_64/07227811-icinga2/icinga2.spec
```
Build the source rpm file
```sh
mv v2.14.2.tar.gz icinga2-2.14.2.tgz
mock --dnf --clean --spec icinga2.spec --sources=. --result=result --build
```
This should generate a source rpm file with the name based on the system, e.g. result/icinga2-2.14.2.el9.src.rpm
Build the binary rpm package files based on the generated source rpm file
```sh
mock --dnf --clean --sources=. --result=result --rebuild result/icinga2-2.14.2.el9.src.rpm
```
This results in multiple rpm files within the "result" directory which can be published via a public repository and then installed on other systems
