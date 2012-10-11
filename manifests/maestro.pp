# This class is used to install and configure the Maestro server.
#
#  Note that admin_password needs to validate against the password rules (letters+numbers by default)
#
# ==Parameters
#
# [repo]  A hash containing the artifact repository URL and credentials.
# [version] The version to install
# [package_type] Selects the type of package to use for the install. Either rpm, or tarball.
# [ldap] A hash containing the LDAP connection parameters. hostname, ssl, port, dn, bind_dn, bind_password, admin_user
# [enabled] Enables/disables the service
# [lucee] Set to true to install lucee locally.
# [admin] the maestro admin user
# [admin_password] the maestro admin user password
# [master_password] the master password
# [db_server_password] the database server password
# [db_password] the database user password
# [db_version] the PostgreSQL version.
# [db_allowed_rules] an array used to configure PostgreSQL access control.
# [db_datadir] the data directory used by PostgreSQL
# [initmemory] configures the initial memory for the JVM running Maestro
# [maxmemory] configures the max memory for the JVM running Maestro
# [permsize] configures the initial permsize for the JVM running Maestro
# [maxpermsize] configures the max permsize for the JVM running Maestro
# [port] the port maestro should be configured to listen on.
# [lucee_url] the URL for the LUCEE API
# [lucee_password] the lucee user password
# [lucee_username] the lucee user name
# [jetty_forwarded] set to true to indicate that jetty is being forwarded by a proxy.
# [mail_from] A hash containing the origin information for emails sent by maestro. name, address.
#
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
  $agent_auto_activate = false,
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
  $basedir = "/var/local/maestro"
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

  $base_version = baseversion($version)

  if $lucee {
    package { [ 'libxslt-devel', 'libxml2-devel' ]: ensure => installed }

    class { 'maestro::lucee':
      agent_auto_activate => $agent_auto_activate,
      password => $db_password,
      
      require => Package[ 'libxslt-devel', 'libxml2-devel' ],
      before  => Service['maestro'],
    }

    file { "${basedir}/conf/lucee-lib.json":
      mode    =>  "0600",
      content =>  template("maestro/lucee-lib.json.erb"),
      require => Class['maestro::maestro::package'],
      notify  => Service[maestro],
    } ->
    # legacy hardcoded location
    file { "/var/maestro":
      ensure => directory,
    } ->
    file { "/var/maestro/lucee-lib.json":
      ensure => link,
      force  => true,
      target => "${basedir}/conf/lucee-lib.json",
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
  class { 'maestro::maestro::package': } -> 
  class { 'maestro::maestro::securityconfig': } -> 
  class { 'maestro::maestro::config': } -> 
  class { 'maestro::maestro::service': }

  
}
