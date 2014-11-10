
############################Ensure SSH Client has been installed if not present on client node ################

package {"openssh-client":
    ensure => "present",
    before=> File['/etc/ssh/sshd_config'],
    }
##########################Disable root Login on client node ##################################################

file {'/etc/ssh/sshd_config':
  ensure => file,
  mode => 0600,
  source => "puppet:///modules/sshd/sshd_config",
  }
###########################Ensure SSH Service is running on server & restart the ssh service when ever sshd_config file chnage###
####################################
 service {'ssh':
   ensure => running,
   enable => true,
   subscribe => File['/etc/ssh/sshd_config'],
 }

##########################pull the standard source.list file from puppet master server#############
file {'/etc/apt/sources.list':
   ensure => "present",
   mode => "0644",
   owner => root,
   group => root,
   source => "puppet:///modules/debian/sources.list",
}

#################Mysql Configuration using puppet pull the standard my.cnf file from puppet module ####################
####################################################################

package { "mariadb-server":
    ensure => "installed",
    before => File['/etc/mysql/my.cnf'],
}
###########################################Set the paramaerts of Mariadb file
 file { "/etc/mysql/my.cnf":
    ensure => "file",
    owner => "mysql",
    group => "mysql",
    mode => "0644",
    source => "puppet:///modules/mysql/my.cnf",

  }
############################################Mysql Data directory Path#############
file { "/var/lib/mysql/":
   ensure => "present",
   owner => "mysql",
   group => "mysql",
   mode => "0755",
}

#################################
service {'mysql':
   ensure => running,
   enable => true,
  subscribe => File['/etc/mysql/my.cnf'],
}
#####################################################Drop database test#############
##################################################################################
exec{"drop database name":
   command => "mysql -u root -pcloud -e \" drop database test;\"",
   path => "/usr/local/bin/:/bin/:/usr/bin",
}
#####################################Create database Zabbix############################
######################################################################################

exec{"create database zabbix":
    command => "mysql -u root -pcloud -e \" create database zabbix;\"",
     path => "/usr/local/bin/:/sbin/:/usr/bin",
}
####################################Rename User root to jioteam User ####################
#######################################################################################
#exec{"rename user from root to jioteam":
#  command => "mysql -u root -pcloud -e \" rename user root@localhost to jioteam@localhost;\"",
#   path => "/usr/local/bin:/sbin:/usr/bin",
#}

####################################Flush the mysql table to update the user details################
###################################################################################################
exec{"flush the mysql tables":
  command => "mysql -u root -pcloud -e \" flush privileges;\"",
  path => "/usr/local/bin:/sbin:/usr/bin",
}
####################Null the Mysql history table###################
exec{"Null the value of /root/.histroy":
  command => "cat /dev/null > /root/.mysql_history",
path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
}

####################################Null the Mysql Histry table #########################
#####################################################################################

