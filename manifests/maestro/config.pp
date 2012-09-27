class maestro::maestro::config($repo = $maestro::maestro::repo,
    $version = $maestro::maestro::version,
    $ldap = $maestro::maestro::ldap, 
    $enabled = $maestro::maestro::enabled, 
    $lucee = $maestro::maestro::lucee,
    $admin = $maestro::maestro::admin,
    $admin_password = $maestro::maestro::admin_password,
    $db_server_password = $maestro::maestro::db_server_password,
    $db_password = $maestro::maestro::db_password,
    $db_version = $maestro::maestro::db_version,
    $db_allowed_rules = $maestro::maestro::db_allowed_rules,
    $db_datadir = $maestro::maestro::db_datadir,
    $initmemory = $maestro::maestro::initmemory,
    $maxmemory = $maestro::maestro::maxmemory,
    $permsize = $maestro::maestro::permsize,
    $maxpermsize = $maestro::maestro::maxpermsize,
    $port = $maestro::maestro::port,
    $lucee_url = $maestro::maestro::lucee_url,
    $lucee_password = $maestro::maestro::lucee_password,
    $lucee_username = $maestro::maestro::lucee_username,
    $jetty_forwarded = $maestro::maestro::jetty_forwarded,
    $srcdir = $maestro::maestro::srcdir,
    $installdir = $maestro::maestro::installdir,
    $basedir = $maestro::maestro::basedir,
    $homedir = $maestro::maestro::homedir) inherits maestro::params {
      
      File {
        owner => $user,
        group => $group,
      }
      # Configure Maestro
      file { "${basedir}/conf/jetty.xml":
        mode    =>  "0600",
        content =>  template("maestro/jetty.xml.erb"),
        require => File["${basedir}/conf"],
      }
      file { "${basedir}/conf/plexus.xml":
        mode    =>  "0600",
        content =>  template("maestro/plexus.xml.erb"),
        require => File["${basedir}/conf"],
      }  
      file { "${homedir}/apps/maestro/WEB-INF/users.properties":
        mode    =>  "0600",
        content =>  template("maestro/users.properties.erb"),
        require => Class['maestro::maestro::package'],
      }
      
      file { "$basedir/conf/wrapper.conf":
         ensure => link,
         target => "$homedir/conf/wrapper.conf",
         require => [Class['maestro::maestro::package'], File["${basedir}/conf"]],
       }

       file { "$basedir/conf/webdefault.xml":
         ensure => link,
         target => "$homedir/conf/webdefault.xml",
         require => [Class['maestro::maestro::package'], File["${basedir}/conf"]],
       }

       file { "$basedir/conf/jetty-jmx.xml":
         ensure => link,
         target => "$homedir/conf/jetty-jmx.xml",
         require => [Class['maestro::maestro::package'], File["${basedir}/conf"]],
       }


      # This requires something, but what? ->
      augeas { "update-default-configurations":
        changes => [
          "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
          "rm default-configuration/users/*[username/#text != 'admin']",
        ],
        incl => "${homedir}/conf/default-configurations.xml",
        lens => "Xml.lns",
        require => Class['maestro::maestro::package'],
      } ->
      file { "${basedir}/conf/default-configurations.xml":
        source  => "${homedir}/conf/default-configurations.xml",
        require => File["${basedir}/conf"],
      }

      # Until Augeas has the properties files fixes, use a custom version
      # Just a basic approach - for more complete management of lenses consider https://github.com/camptocamp/puppet-augeas
      if !defined(File["/tmp/augeas"]) {
        file { "/tmp/augeas": ensure => directory }
      }
      file { "/tmp/augeas/maestro": ensure => directory } ->
      wget::fetch { "fetch-augeas-maestro":
        source => "https://raw.github.com/maestrodev/augeas/af585c7e29560306f23938b3ba15aa1104951f7f/lenses/properties.aug",
        destination => "/tmp/augeas/maestro/properties.aug",
      } ->
      augeas { "show-snapshot-version":
        lens      => "Properties.lns",
        incl      => "${homedir}/apps/maestro/WEB-INF/classes/filterValues.properties",
        changes   => "set artifactVersion ${version}",
        load_path => '/tmp/augeas/maestro',
        require => Class['maestro::maestro::package'],
      }

      if $::architecture == "x86_64" {
        file { "${homedir}/bin/wrapper-linux-x86-32":
          ensure => absent,
          require => Class['maestro::maestro::package'],
          before => Service[maestro],
        }
      }

      # set memory configuration
      $wrapper = "${homedir}/conf/wrapper.conf"
      exec { 'maestro-memory-init':
        command => "sed -i 's/wrapper\\.java\\.initmemory=.*$/wrapper\\.java\\.initmemory=${initmemory}/' ${wrapper}",
        unless  => "grep 'wrapper.java.initmemory=${initmemory}' ${wrapper}",
        require => Class['maestro::maestro::package'],
        notify  => Service['maestro'],
      }
      exec { 'maestro-memory-max':
        command => "sed -i 's/wrapper\\.java\\.maxmemory=.*$/wrapper\\.java\\.maxmemory=${maxmemory}/' ${wrapper}",
        unless  => "grep 'wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
        require => Class['maestro::maestro::package'],
        notify  => Service['maestro'],
      }
  
}
