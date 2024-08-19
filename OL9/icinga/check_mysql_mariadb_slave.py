#!/usr/bin/env python3

import time
import sys

if sys.version_info.major == 2:
    import ConfigParser as configparser
else:
    import configparser
import pymysql, smtplib
from optparse import OptionParser

###################################################
# Exit statuses recognized by Nagios
status_for_nagios = {}

status_for_nagios["OK"] = 0
status_for_nagios["WARNING"] = 1
status_for_nagios["CRITICAL"] = 2
status_for_nagios["UNKNOWN"] = 3

###################################################
parser = OptionParser()
parser.add_option("-H", "--hostname", dest="hostname")
parser.add_option("-d", "--db", dest="db", default="mysql")
parser.add_option("-w", "--warning", dest="w_threshold", type="int", default=900)
parser.add_option("-c", "--critical", dest="c_threshold", type="int", default=1200)
options, args = parser.parse_args()

# print "options.hostname = %s" % (options.hostname)


def _config(file, section, option):
    cf = configparser.ConfigParser()
    cf.read(file)
    return cf.get(section, option)


def _mysql_query(host, port, user, passwd, query):
    connection = pymysql.connect(
        host=host,
        user=user,
        password=passwd,
        port=int(port),
    )
    with connection.cursor() as cursor:
        cursor.execute(query)
        return cursor.fetchall()


config_file = "/etc/icinga2/conf.d/bp/plugins_config/check_mysql_slave.ini"
db_section = "DB"
mail_section = "MAIL"
slave_section = "CREDENTIALS"

##config slave options
config_slave_host = options.hostname
config_slave_port = _config(config_file, slave_section, "Port")
config_slave_user = _config(config_file, slave_section, "User")
config_slave_pass = _config(config_file, slave_section, "Pass")

# query slave status info SQL
slave_status = "show slave status"


current_time = time.strftime("%Y-%m-%d %H:%M:%S")
mail_message = ""
slave_result = _mysql_query(
    config_slave_host,
    config_slave_port,
    config_slave_user,
    config_slave_pass,
    slave_status,
)



if options.db == "mysql":
    (
        (
            Slave_IO_State,
            Master_Host,
            Master_User,
            Master_Port,
            Connect_Retry,
            Master_Log_File,
            Read_Master_Log_Pos,
            Relay_Log_File,
            Relay_Log_Pos,
            Relay_Master_Log_File,
            Slave_IO_Running,
            Slave_SQL_Running,
            Replicate_Do_DB,
            Replicate_Ignore_DB,
            Replicate_Do_Table,
            Replicate_Ignore_Table,
            Replicate_Wild_Do_Table,
            Replicate_Wild_Ignore_Table,
            Last_Errno,
            Last_Error,
            Skip_Counter,
            Exec_Master_Log_Pos,
            Relay_Log_Space,
            Until_Condition,
            Until_Log_File,
            Until_Log_Pos,
            Master_SSL_Allowed,
            Master_SSL_CA_File,
            Master_SSL_CA_Path,
            Master_SSL_Cert,
            Master_SSL_Cipher,
            Master_SSL_Key,
            Seconds_Behind_Master,
            Master_SSL_Verify_Server_Cert,
            Last_IO_Errno,
            Last_IO_Error,
            Last_SQL_Errno,
            Last_SQL_Error,
            Replicate_Ignore_Server_Ids,
            Master_Server_Id,
            Master_UUID,
            Master_Info_File,
            SQL_Delay,
            SQL_Remaining_Delay,
            Slave_SQL_Running_State,
            Master_Retry_Count,
            Master_Bind,
            Last_IO_Error_Timestamp,
            Last_SQL_Error_Timestamp,
            Master_SSL_Crl,
            Master_SSL_Crlpath,
            Retrieved_Gtid_Set,
            Executed_Gtid_Set,
            Auto_Position,
        ),
    ) = slave_result

if options.db == "mariadb":
    (
        (
            Slave_IO_State,
            Master_Host,
            Master_User,
            Master_Port,
            Connect_Retry,
            Master_Log_File,
            Read_Master_Log_Pos,
            Relay_Log_File,
            Relay_Log_Pos,
            Relay_Master_Log_File,
            Slave_IO_Running,
            Slave_SQL_Running,
            Replicate_Do_DB,
            Replicate_Ignore_DB,
            Replicate_Do_Table,
            Replicate_Ignore_Table,
            Replicate_Wild_Do_Table,
            Replicate_Wild_Ignore_Table,
            Last_Errno,
            Last_Error,
            Skip_Counter,
            Exec_Master_Log_Pos,
            Relay_Log_Space,
            Until_Condition,
            Until_Log_File,
            Until_Log_Pos,
            Master_SSL_Allowed,
            Master_SSL_CA_File,
            Master_SSL_CA_Path,
            Master_SSL_Cert,
            Master_SSL_Cipher,
            Master_SSL_Key,
            Seconds_Behind_Master,
            Master_SSL_Verify_Server_Cert,
            Last_IO_Errno,
            Last_IO_Error,
            Last_SQL_Errno,
            Last_SQL_Error,
            Replicate_Ignore_Server_Ids,
            Master_Server_Id,
            Master_SSL_Crl,
            Master_SSL_Crlpath,
            Using_Gtid,
            Gtid_IO_Pos,
            Replicate_Do_Domain_Ids,
            Replicate_Ignore_Domain_Ids,
            Parallel_Mode,
        ),
    ) = slave_result

if options.db == "mariadb106":
    (
        (
            Slave_IO_State,
            Master_Host,
            Master_User,
            Master_Port,
            Connect_Retry,
            Master_Log_File,
            Read_Master_Log_Pos,
            Relay_Log_File,
            Relay_Log_Pos,
            Relay_Master_Log_File,
            Slave_IO_Running,
            Slave_SQL_Running,
            Replicate_Do_DB,
            Replicate_Ignore_DB,
            Replicate_Do_Table,
            Replicate_Ignore_Table,
            Replicate_Wild_Do_Table,
            Replicate_Wild_Ignore_Table,
            Last_Errno,
            Last_Error,
            Skip_Counter,
            Exec_Master_Log_Pos,
            Relay_Log_Space,
            Until_Condition,
            Until_Log_File,
            Until_Log_Pos,
            Master_SSL_Allowed,
            Master_SSL_CA_File,
            Master_SSL_CA_Path,
            Master_SSL_Cert,
            Master_SSL_Cipher,
            Master_SSL_Key,
            Seconds_Behind_Master,
            Master_SSL_Verify_Server_Cert,
            Last_IO_Errno,
            Last_IO_Error,
            Last_SQL_Errno,
            Last_SQL_Error,
            Replicate_Ignore_Server_Ids,
            Master_Server_Id,
            Master_SSL_Crl,
            Master_SSL_Crlpath,
            Using_Gtid,
            Gtid_IO_Pos,
            Replicate_Do_Domain_Ids,
            Replicate_Ignore_Domain_Ids,
            Parallel_Mode,
            SQL_Delay,
            SQL_Remaining_Delay,
            Slave_SQL_Running_State,
            Slave_DDL_Groups,
            Slave_Non_Transactional_Groups,
            Slave_Transactional_Groups,
        ),
    ) = slave_result

# Conditions
if Slave_IO_Running != "Yes":
    critical_flag = True
    print(
        "CRITICAL - Slave_IO_Running on %s = %s" % (config_slave_host, Slave_IO_Running)
    )
    sys.exit(status_for_nagios["CRITICAL"])


if Slave_SQL_Running != "Yes":
    critical_flag = True
    print(
        "CRITICAL - Slave_SQL_Running on %s = %s"
        % (config_slave_host, Slave_SQL_Running)
    )
    sys.exit(status_for_nagios["CRITICAL"])

if Last_Error != "":
    print(
        "CRITICAL - Slave_IO_Running on %s = %s" % (config_slave_host, Slave_IO_Running)
    )
    sys.exit(status_for_nagios["CRITICAL"])
    critical_flag = True

if (
    Seconds_Behind_Master > options.w_threshold
    and Seconds_Behind_Master <= options.c_threshold
):
    critical_flag = True

    print(
        "WARNING - Seconds_Behind_Master on %s = %s"
        % (config_slave_host, Seconds_Behind_Master)
    )
    sys.exit(status_for_nagios["WARNING"])

if Seconds_Behind_Master > options.c_threshold:
    critical_flag = True

    print(
        "CRITICAL - Seconds_Behind_Master on %s = %s"
        % (config_slave_host, Seconds_Behind_Master)
    )
    sys.exit(status_for_nagios["CRITICAL"])

print(
    "OK - Slave is running on %s. Master is %s. Seconds Behind Master: %s"
    % (config_slave_host, Master_Host, Seconds_Behind_Master)
)
sys.exit(status_for_nagios["OK"])
