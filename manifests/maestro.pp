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
  $homedir = "/usr/local/maestro",
  $basedir = "/var/local/maestro",
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

    class { 'maestro::lucee':
      require => Package[ 'libxslt-devel', 'libxml2-devel' ],
      before  => Service['maestro'],
    }

    file { "${basedir}/lucee-lib.json":
      mode    =>  "0600",
      content =>  template("maestro/lucee-lib.json.erb"),
      require => Exec["maestro"],
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

  wget::authfetch { "fetch-maestro":
    user => $repo['username'],
    password => $repo['password'],
    source => "${repo['url']}/com/maestrodev/maestro/maestro-jetty/$base_version/maestro-jetty-${version}-bin.tar.gz",
    destination => "$srcdir/maestro-jetty-${version}-bin.tar.gz",
  } ->
  exec {"rm -rf $installdir/maestro-${base_version}":
     unless => "egrep \"^${version}$\" $srcdir/maestro-jetty.version",
  } ->
  exec { "maestro":
    command => "tar zxvf $srcdir/maestro-jetty-${version}-bin.tar.gz",
    creates => "$installdir/maestro-$base_version",
    cwd => $installdir,
  } ->
  exec { "chown -R ${user} ${installdir}/maestro-$base_version":
    require => User[$user],
  } ->
  file { "$installdir/maestro-$base_version/bin":
    mode => 755,
    recurse => true,
  } ->
  file { "$homedir":
    ensure => link,
    target => "$installdir/maestro-$base_version"
  } ->
  file { "${homedir}/apps/maestro/WEB-INF/users.properties":
    mode    =>  "0600",
    content =>  template("maestro/users.properties.erb"),
  }

  exec { "echo $version >$srcdir/maestro-jetty.version":
    require => Exec[maestro],
  } ->
  # Touch the installation package even if current, so that it isn't deleted
  exec { "touch $srcdir/maestro-jetty-${version}-bin.tar.gz":
  } ->
  tidy { "tidy-maestro":
    age => "1d",
    matches => "maestro-jetty-*",
    recurse => true,
    path => $srcdir,
  }

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
  } ->
  file { "${basedir}/conf/security.properties":
    mode    =>  "0644",
    content =>  template("maestro/security.properties.erb"),
  } ->
  file { "${basedir}/conf/jetty.xml":
    mode    =>  "0600",
    content =>  template("maestro/jetty.xml.erb"),
  } ->
  file { "${basedir}/conf/plexus.xml":
    mode    =>  "0600",
    content =>  template("maestro/plexus.xml.erb"),
  } ->
  exec { "chown -R ${user} ${basedir}":
  } ->
  file { "$basedir/conf/wrapper.conf":
    ensure => link,
    target => "$homedir/conf/wrapper.conf",
    require => File[$homedir],
  } ->
  file { "$basedir/conf/webdefault.xml":
    ensure => link,
    target => "$homedir/conf/webdefault.xml"
  } ->
  file { "$basedir/conf/jetty-jmx.xml":
    ensure => link,
    target => "$homedir/conf/jetty-jmx.xml"
  } ->
  augeas { "update-default-configurations":
    changes => [
      "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
      "rm default-configuration/users/*[username/#text != 'admin']",
    ],
    incl => "${homedir}/conf/default-configurations.xml",
    lens => "Xml.lns",
  } ->
  file { "${basedir}/conf/default-configurations.xml":
    source  => "${homedir}/conf/default-configurations.xml",
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
    require   => File[$homedir],
  }

  if $::architecture == "x86_64" {
    file { "${homedir}/bin/wrapper-linux-x86-32":
      ensure => absent,
      require => Exec['maestro'],
      before => Service[maestro],
    }
  }

  # set memory configuration
  $wrapper = "${homedir}/conf/wrapper.conf"
  exec { 'maestro-memory-init':
    command => "sed -i 's/wrapper\.java\.initmemory=.*$/wrapper\.java\.initmemory=${initmemory}/' ${wrapper}",
    unless  => "grep 'wrapper.java.initmemory=${initmemory}' ${wrapper}",
    require => File[$homedir],
    notify  => Service['maestro'],
  }
  exec { 'maestro-memory-max':
    command => "sed -i 's/wrapper\.java\.maxmemory=.*$/wrapper\.java\.maxmemory=${maxmemory}/' ${wrapper}",
    unless  => "grep 'wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
    require => File[$homedir],
    notify  => Service['maestro'],
  }

  file { "/etc/init.d/maestro":
    owner => "root",
    mode  => "0755",
    content => template("maestro/maestro.erb"),
    require => Exec["maestro"],
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
    require => [Exec["maestro"],
                File["/etc/init.d/maestro"], 
                Class["maestro::maestro-postgres"]],
    subscribe => [File["${basedir}/conf/jetty.xml"], 
                  File["${basedir}/conf/security.properties"]],
  }  
}
