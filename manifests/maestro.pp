# note that admin_password needs to validate against the password rules (letters+numbers by default)
class maestro::maestro( $repo = $maestrodev_repo,
  $version = $maestro_version,
  $package_type = 'tarball',
  $ldap = {}, 
  $enabled = true, 
  $lucee = true,
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
  $basedir = "/var/maestro"
  $homedir = "/usr/local/maestro"
  
  Exec { path => "/bin/:/usr/bin", }
  File {
    owner => $user,
    group => $group,
  }
  
  # Create the basedir. Where config and logs belong for this
   # particular maestro instance.

   file { $basedir:
      ensure => directory,
    } ->
    file { "$basedir/conf":
      ensure => directory,
    } ->
    file { "$basedir/logs":
      ensure => directory,
    } ->
    file { "$basedir/tmp":
      ensure => directory,
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

    class { 'maestro::lucee':
      require => Package[ 'libxslt-devel', 'libxml2-devel' ],
      before  => Service['maestro'],
    }

    file { "${basedir}/lucee-lib.json":
      mode    =>  "0600",
      content =>  template("maestro/lucee-lib.json.erb"),
      require => Class['maestro::maestro::package'],
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

  class { 'maestro::maestro-postgres':  } ->   
  class { 'maestro::maestro::package': } -> class { 'maestro::maestro::config': } -> class { 'maestro::maestro::service': }

  
}
