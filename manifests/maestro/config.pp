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
    $homedir = $maestro::maestro::homedir,
    $enable_jpda = $maestro::maestro::enable_jpda,
    $jmxport = $maestro::maestro::jmxport,
    $rmi_server_hostname = $maestro::maestro::rmi_server_hostname,
    $ga_property_id = $maestro::maestro::ga_property_id) inherits maestro::params {

  $wrapper = "${homedir}/conf/wrapper.conf"
  $configdir = "${basedir}/conf"


  File {
    owner => $maestro::params::user,
    group => $maestro::params::group,
  }
  # Configure Maestro
  if !defined( File["${configdir}/jetty.xml"] ) {
    file { "${configdir}/jetty.xml":
      mode    => '0600',
      content => template('maestro/jetty.xml.erb'),
      require => File[$configdir],
    }
  }
  file { "${configdir}/plexus.xml":
    mode    => '0600',
    content => template('maestro/plexus.xml.erb'),
    require => File[$configdir],
  }

  file { "${configdir}/jetty-jmx.xml":
    mode    => '0600',
    content => template('maestro/jetty-jmx.xml.erb'),
    require => File[$configdir],
  }

  file { "${configdir}/maestro.properties":
    mode    => '0600',
    content => template('maestro/maestro.properties.erb'),
    require => File[$configdir],
  }

  file { "${configdir}/lucee-lib.json":
    mode    => '0600',
    content => template('maestro/lucee-lib.json.erb'),
    require => File[$configdir],
    notify  => Service['maestro'],
  }
  if versioncmp($version, "4.13.0") >= 0 {
    # remove legacy hardcoded location
    file { '/var/maestro/lucee-lib.json':
      ensure => absent,
      require => Class['maestro::maestro::package'],
    }
  }
  else {
    # legacy hardcoded location
    file { '/var/maestro':
      ensure => directory,
    } ->
    file { '/var/maestro/lucee-lib.json':
      ensure => link,
      force  => true,
      target => "${basedir}/conf/lucee-lib.json",
    }
  }

  # Create symlinks to some files provided by the distribution package

  file { "${configdir}/wrapper.conf":
    ensure  => link,
    target  => $wrapper,
    require => [Class['maestro::maestro::package'], File[$configdir]],
  }

  file { "${configdir}/webdefault.xml":
    ensure  => link,
    target  => "${homedir}/conf/webdefault.xml",
    require => [Class['maestro::maestro::package'], File[$configdir]],
  }

  file { "${configdir}/default-configurations.xml":
    ensure  => link,
    target  => "${homedir}/conf/default-configurations.xml",
    require => [Class['maestro::maestro::package'], File[$configdir]],
  }

  # Until Augeas has the properties files fixes, use a custom version
  # Just a basic approach - for more complete management of lenses consider https://github.com/camptocamp/puppet-augeas
  if !defined(File['/tmp/augeas']) {
    file { '/tmp/augeas': ensure => directory }
  }
  file { '/tmp/augeas/maestro':
    ensure => directory,
    require => File['/tmp/augeas'],
  } ->
  file { "/tmp/augeas/maestro/properties.aug":
    source => "puppet:///modules/maestro/properties.aug"
  }

  # Tweak the files provided in the distribution as these cannot be templated easily or in a portable fashion.

  augeas { 'update-default-configurations':
    changes => [
      "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
      "rm default-configuration/users/*[username/#text != 'admin']"
    ],
    incl    => "${homedir}/conf/default-configurations.xml",
    lens    => 'Xml.lns',
    require => Class['maestro::maestro::package'],
  }

  Augeas {
    lens      => "Properties.lns",
    load_path => '/tmp/augeas/maestro',
    require   => [Class['maestro::maestro::package'], File['/tmp/augeas/maestro/properties.aug']],
    notify    => Service['maestro'],
  }

  augeas { 'show-snapshot-version':
    incl      => "${homedir}/apps/maestro/WEB-INF/classes/filterValues.properties",
    changes   => "set artifactVersion ${version}",
  }

  augeas { 'maestro-wrapper':
    incl      => $wrapper,
    changes   => [
      "set wrapper.java.initmemory ${initmemory}",
      "set wrapper.java.maxmemory ${maxmemory}",
      "set wrapper.java.additional.8 -XX:PermSize=${permsize}",
      "set wrapper.java.additional.9 -XX:MaxPermSize=${maxpermsize}"
    ],
  }
  # Makes sure we are not overwriting anything else that might have been configured in wrapper.java.additional.10
  # before doing this...
  if $enable_jpda {
    augeas { 'maestro-jpda':
      incl      => $wrapper,
      changes   => 'set wrapper.java.additional.10 -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n',
    }
  }

  if $::architecture == 'x86_64' {
    file { "${homedir}/bin/wrapper-linux-x86-32":
      ensure  => absent,
      require => Class['maestro::maestro::package'],
      before  => Service[maestro],
    }
  }
}
