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
# [enable_jpda] A boolean indicating whether or not we want to enable JPDA
# [jmxport] The port number the JMX server will listen on (default 9001)
# [rmi_server_hostname] The ip address the JMX server will listen on (default $ipaddress)
# [web_config_properties] properties to add the maestro.properties, such as a feature toggles
# [ga_property_id] the google analytics property id
#
class maestro::maestro(
  $repo = $maestrodev_repo,
  $version = $maestro_version,
  $package_type = 'tarball',
  $ldap = {},
  $enabled = true,
  $lucee = true,
  $metrics_enabled = false,
  $admin = 'admin',
  $admin_password = $maestro_adminpassword,
  $master_password = $maestro_master_password,
  $db_server_password = $maestro_db_server_password,
  $db_password = $maestro_db_password,
  $db_version = undef,
  $db_allowed_rules = [],
  $initmemory = '512',
  $maxmemory = '1536',
  $permsize = '384m',
  $maxpermsize = '384m',
  $port = '8080',
  $agent_auto_activate = false,
  $enable_jpda = false,
  $jmxport = '9001',
  $rmi_server_hostname = 'localhost',
  $lucee_url = 'http://localhost:8080/lucee/api/v0/',
  $lucee_password = 'maestro',
  $lucee_username = 'maestro',
  $jetty_forwarded = $::jetty_forwarded,
  $mail_from = {
    name    => 'Maestro',
    address => 'info@maestrodev.com'
  },
  $web_config_properties = {},
  $ga_property_id = '') inherits maestro::params {

  $srcdir = '/usr/local/src'
  $installdir = '/usr/local'
  $basedir = '/var/local/maestro'
  $homedir = '/usr/local/maestro'


  Exec { path => '/bin/:/usr/bin', }
  File {
    owner => $maestro::params::user,
    group => $maestro::params::group,
  }

  # Create the basedir. Where config and logs belong for this
  # particular maestro instance.

  file { $basedir:
    ensure => directory,
  } ->
  file { "${basedir}/conf":
    ensure => directory,
  } ->
  file { "${basedir}/logs":
    ensure => directory,
  } ->
  file { "${basedir}/tmp":
    ensure => directory,
  }

  $base_version = snapshotbaseversion($version)

  if $lucee {
    # For maestro versions older than 4.12.0 we need some more packages
    if versioncmp($version, '4.12.0') < 0 {
      if ! defined(Package['libxslt-devel']) {
        package { 'libxslt-devel':
          ensure => installed,
          before => Class['maestro::lucee'],
        }
      }
      if ! defined(Package['libxml2-devel']) {
        package { 'libxml2-devel':
          ensure => installed,
          before => Class['maestro::lucee'],
        }
      }
    }

    class { 'maestro::lucee':
      config_dir          => "${basedir}/conf",
      agent_auto_activate => $agent_auto_activate,
      password            => $db_password,
      require             => File["${basedir}/conf"],
      before              => Service['maestro'],
      metrics_enabled     => $metrics_enabled,
    }

    # plugin folder
    file { "${user_home}/.maestro" :
      ensure  => directory,
      require => User[$maestro::params::user],
    } ->
    file { "${user_home}/.maestro/plugins" :
      ensure => directory,
    }
  }

  class { 'maestro::maestro::db':  } ->
  class { 'maestro::maestro::package': } ->
  class { 'maestro::maestro::securityconfig': } ->
  class { 'maestro::maestro::config': } ->
  class { 'maestro::maestro::service': }

}
