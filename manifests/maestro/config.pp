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

  File {
    owner => $maestro::params::user,
    group => $maestro::params::group,
  }
  # Configure Maestro
  if !defined( File["${basedir}/conf/jetty.xml"] ) {
    file { "${basedir}/conf/jetty.xml":
      mode    => '0600',
      content => template('maestro/jetty.xml.erb'),
      require => File["${basedir}/conf"],
    }
  }
  file { "${basedir}/conf/plexus.xml":
    mode    => '0600',
    content => template('maestro/plexus.xml.erb'),
    require => File["${basedir}/conf"],
  }

  file { "${basedir}/conf/wrapper.conf":
    content => template('maestro/wrapper.conf.erb'),
    require => File["${basedir}/conf"],
  }

  file { "${basedir}/conf/webdefault.xml":
    ensure  => link,
    target  => "${homedir}/conf/webdefault.xml",
    require => [Class['maestro::maestro::package'], File["${basedir}/conf"]],
  }

  file { "${basedir}/conf/jetty-jmx.xml":
    mode    => '0600',
    content => template('maestro/jetty-jmx.xml.erb'),
    require => File["${basedir}/conf"],
  }

  file { "${basedir}/conf/maestro.properties":
    mode    => '0600',
    content => template('maestro/maestro.properties.erb'),
    require => File["${basedir}/conf"],
  }

  # This requires something, but what? ->
  augeas { 'update-default-configurations':
    changes => [
      "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
      "rm default-configuration/users/*[username/#text != 'admin']",
    ],
    incl    => "${homedir}/conf/default-configurations.xml",
    lens    => 'Xml.lns',
    require => Class['maestro::maestro::package'],
  } ->
  file { "${basedir}/conf/default-configurations.xml":
    source  => "${homedir}/conf/default-configurations.xml",
    require => File["${basedir}/conf"],
  }

  # Until Augeas has the properties files fixes, use a custom version
  # Just a basic approach - for more complete management of lenses consider https://github.com/camptocamp/puppet-augeas
  if !defined(File['/tmp/augeas']) {
    file { '/tmp/augeas': ensure => directory }
  }
  file { '/tmp/augeas/maestro': ensure => directory } ->
  file { "/tmp/augeas/maestro/properties.aug":
    source => "puppet:///modules/maestro/properties.aug"
  }->
  augeas { 'show-snapshot-version':
    lens      => 'Properties.lns',
    incl      => "${homedir}/apps/maestro/WEB-INF/classes/filterValues.properties",
    changes   => "set artifactVersion ${version}",
    load_path => '/tmp/augeas/maestro',
    require   => Class['maestro::maestro::package'],
  }

  if $::architecture == 'x86_64' {
    file { "${homedir}/bin/wrapper-linux-x86-32":
      ensure  => absent,
      require => Class['maestro::maestro::package'],
      before  => Service[maestro],
    }
  }
}
