# note that admin_password needs to validate against the password rules (letters+numbers by default)
class maestro::maestro( $repo = $maestrodev_repo,
  $version = $maestro_version,
  $ldap = {}, $enabled = true, $lucee = true,
  $admin = 'admin',
  $admin_password = $maestro_adminpassword,
  $master_password = $maestro_master_password,
  $db_server_password = $maestro_db_server_password,
  $db_password = $maestro_db_password,
  $db_version = '',
  $db_allowed_rules = [],
  $db_datadir = '/var/lib/pgsql/data',
  $initmemory = '512',
  $maxmemory = '1536',
  $permsize = '384m',
  $maxpermsize = '384m',
  $port = '8080',
  $lucee_url = "http://localhost:8080/lucee/api/v0/",
  $lucee_password = "maestro",
  $lucee_username = "maestro",
  $jetty_forwarded = $::jetty_forwarded,
  $mail_from = {
    name    => 'Maestro',
    address => 'info@maestrodev.com'
  }) inherits maestro::params {
  
  $srcdir = "/usr/local/src"
  $installdir = "/usr/local"
  # These are no longer class parameters because the RPM has those as hard-coded values.
  $homedir = "/usr/local/maestro"
  $basedir = "/var/local/maestro"
  
  Exec { path => "/bin/:/usr/bin", }
  File {
    owner => $user,
    group => $group,
  }

  # TODO: put this in a library so it can be reused
  # If the version is a Maven snapshot, transform the base version to it's
  # SNAPSHOT indicator
  if $version =~ /^(.*)-[0-9]{8}\.[0-9]{6}-[0-9]+$/ {
    $base_version = "${1}-SNAPSHOT"
  } else {
    $base_version = $version
  } 

  if $lucee {
    package { [ 'libxslt-devel', 'libxml2-devel' ]: ensure => installed }

    if !defined(Class['maestro::lucee::config']) {
      # set lucee config defaults if not set already
      class { 'maestro::lucee::config':
        before => Class['maestro::lucee'],
      }
    }

    class { 'maestro::lucee':
      db_username    => 'maestro',
      db_password    => $db_password,
      db_name        => 'luceedb',
      require        => Package[ 'libxslt-devel', 'libxml2-devel' ],
      before         => Service['maestro'],
      eui            => true,
    }

    file { "${basedir}/lucee-lib.json":
      mode    =>  "0600",
      content =>  template("maestro/lucee-lib.json.erb"),
      require => Package["maestro"],
      notify  => Service[maestro],
    } 

    # plugin folder
    file { "$user_home/.maestro" :
      ensure => directory,
      require => User[$user],
    } ->
    file { "$user_home/.maestro/plugins" :
      ensure => directory,
    }
  }

  class { 'maestro::maestro-postgres':
    version       => $db_version,
    password      => $db_server_password,
    db_password   => $db_password,
    allowed_rules => $db_allowed_rules,
    datadir       => $db_datadir,
  }

  # When we have a proper yum repo, this variable can go away.
   $maestro_source = "https://${repo['username']}:${repo['password']}@${repo['uri']}/com/maestrodev/maestro/rpm/maestro/${base_version}/maestro-${version}.rpm"

   package { 'maestro':
     ensure => $version,
     source => $maestro_source,
     provider => rpm,
   } ->
   file { $homedir:
     ensure => directory,
     owner => $user,
     require => User[$user],
   } ->
   file { "${homedir}/bin":
     mode => 755,
     recurse => true,
   } ->
   file { "${homedir}/apps/maestro/WEB-INF/users.properties":
     mode    =>  "0600",
     content =>  template("maestro/users.properties.erb"),
   }

   exec { "echo $version >$srcdir/maestro-jetty.version":
     require => Package["maestro"],
   } ->
   tidy { "tidy-maestro":
     age => "1d",
     matches => "maestro-jetty-*",
     recurse => true,
     path => $srcdir,
   }

   file { $basedir:
     ensure => directory,
     owner => $user,
     require => User[$user],
   } ->
   file { "$basedir/conf":
     ensure => directory,
     owner => $user,    
   } ->
   file { "$basedir/logs":
     ensure => directory,
     owner => $user,    
   } ->
   file { "$basedir/tmp":
     ensure => directory,
     owner => $user,    
   } ->
   file { "${basedir}/conf/security.properties":
     mode    =>  "0644",
     owner => $user,    
     content =>  template("maestro/security.properties.erb"),
   } ->
   file { "${basedir}/conf/jetty.xml":
     mode    =>  "0600",
     owner => $user,    
     content =>  template("maestro/jetty.xml.erb"),
   } ->
   file { "${basedir}/conf/plexus.xml":
     mode    =>  "0600",
     owner => $user,    
     content =>  template("maestro/plexus.xml.erb"),
   } ->   
   augeas { "update-default-configurations":
     changes => [
       "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
       "rm default-configuration/users/*[username/#text != 'admin']",
     ],
     incl => "${homedir}/conf/default-configurations.xml",
     lens => "Xml.lns",
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
     require => Package['maestro'],
   }

   if $::architecture == "x86_64" {
     file { "${homedir}/bin/wrapper-linux-x86-32":
       ensure => absent,
       require => Package['maestro'],
       before => Service[maestro],
     }
   }

   # set memory configuration
   $wrapper = "${basedir}/conf/wrapper.conf"
   exec { 'maestro-memory-init':
     command => "sed -i 's/wrapper\.java\.initmemory=.*$/wrapper\.java\.initmemory=${initmemory}/' ${wrapper}",
     unless  => "grep 'wrapper.java.initmemory=${initmemory}' ${wrapper}",
     require => Package["maestro"],
     notify  => Service['maestro'],
   }
   exec { 'maestro-memory-max':
     command => "sed -i 's/wrapper\.java\.maxmemory=.*$/wrapper\.java\.maxmemory=${maxmemory}/' ${wrapper}",
     unless  => "grep 'wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
     require => Package["maestro"],
     notify  => Service['maestro'],
   }

   file { "/etc/init.d/maestro":
     owner => "root",
     mode  => "0755",
     content => template("maestro/maestro.erb"),
     require => Package["maestro"],
   }

   # do this only for binary installations, not for webapp deployments
   # Wait for tables to be created on Maestro startup
   # not actually used in the maestro module but useful for other modules that need to depend on maestro db being ready
   $startup_wait_script = "/tmp/startup_wait.sh"
   if $enabled {
     file { $startup_wait_script:
       mode    =>  "0700",
       content =>  template("maestro/startup_wait.sh.erb"),
     } ->
     exec { "${startup_wait_script} ${db_password} >> ${basedir}/logs/maestro_initdb.log 2>&1":
       alias   => "startup_wait",
       timeout => 600,
       #require => [File[$startup_wait_script], Service[maestro], Postgres::Createdb["sonar"]]
       require => [Service[maestro]]
     } ->
     exec { "check-data-upgrade":
       command   => "curl -X POST http://localhost:$port/api/v1/system/upgrade",
       tries     => 30,
       try_sleep => 1,
     }
   }

   service { maestro:
     hasrestart => true,
     hasstatus => true,
     enable => $enabled,
     ensure => $enabled ? { true => running, false => stopped, },
     require => [Package["maestro"],
                 File["/etc/init.d/maestro"], 
                 Class["maestro::maestro-postgres"]],
     subscribe => [File["${basedir}/conf/jetty.xml"], 
                   File["${basedir}/conf/security.properties"]],
   }
}
