 ############Set IST Time on Server ##########################################   
    exec {'tz-set':
    command => '/usr/bin/timedatectl set-timezone Asia/Kolkata',
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
     }     

   $data_volume = ['/usrdata','/usrdata/pgsql','/usrdata/pgsql/data']

###########pgsql package as per given by Engineering Team ###########
    $pgsqlpackages = ["postgresql-9.3","postgresql-contrib-9.3"]

    file {$data_volume:
    ensure => directory,
    owner => postgres,
    group => postgres,
    mode => 0755,
}
###########Pgsql directory structure for logs & other require directory#############
    $pgsql = ['/usrdata/pgsql/data/jdgw','/usrdata/pgsql/data/jio','/usrdata/pgsql/data/switchnwalk','/usrdata/pgsql/logs','/usrdata/pgsql/tablespace']
##########Install the pgsql packages on the server #############
    package { $pgsqlpackages:
    ensure => "installed"
}

    exec {'login_pgsql':
    user => postgres,
    command => "/usr/lib/postgresql/9.3/bin/initdb -D /usrdata/pgsql/data/",
    path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
   }

   file {$pgsql:
   ensure => directory,
   owner => postgres,
   group => postgres,
   mode => 0755,
   }

    file { "/etc/postgresql/9.3/main/pg_hba.conf":
    ensure => "file",
    owner => "postgres",
    group => "postgres",
    mode => "0755",
    source => "puppet:///modules/pgsql/pg_hba.conf",
   } 

    file {"/etc/postgresql/9.3/main/postgresql.conf":
    ensure => "file",
    owner => "postgres",
    group => "postgres",
    mode => "0755",
    source => "puppet:///modules/pgsql/postgresql.conf",
   }

   service {'postgresql':
   ensure => running,
   enable => true,
   subscribe => File["/etc/postgresql/9.3/main/postgresql.conf"],
  }


