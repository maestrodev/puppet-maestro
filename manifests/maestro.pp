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
      require => Class['maestro::package'],
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
   
   # Install the package
   class { 'maestro::package':
    type => $package_type,
    repo => $repo,
    version => $version,
    base_version => $base_version,
    srcdir => $srcdir,
    homedir => $homedir,
    basedir => $basedir,
  }
  
  # Configure Maestro
  file { "${basedir}/conf/security.properties":
    mode    =>  "0644",
    content =>  template("maestro/security.properties.erb"),
    require => File["${basedir}/conf"],
  }
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
    require => Class['maestro::package'],
  }
  
  # This requires something, but what? ->
  augeas { "update-default-configurations":
    changes => [
      "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
      "rm default-configuration/users/*[username/#text != 'admin']",
    ],
    incl => "${homedir}/conf/default-configurations.xml",
    lens => "Xml.lns",
    require => Class['maestro::package'],
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
    require => Class['maestro::package'],
  }

  if $::architecture == "x86_64" {
    file { "${homedir}/bin/wrapper-linux-x86-32":
      ensure => absent,
      require => Class['maestro::package'],
      before => Service[maestro],
    }
  }

  # set memory configuration
  $wrapper = "${homedir}/conf/wrapper.conf"
  exec { 'maestro-memory-init':
    command => "sed -i 's/wrapper\.java\.initmemory=.*$/wrapper\.java\.initmemory=${initmemory}/' ${wrapper}",
    unless  => "grep 'wrapper.java.initmemory=${initmemory}' ${wrapper}",
    require => Class['maestro::package'],
    notify  => Service['maestro'],
  }
  exec { 'maestro-memory-max':
    command => "sed -i 's/wrapper\.java\.maxmemory=.*$/wrapper\.java\.maxmemory=${maxmemory}/' ${wrapper}",
    unless  => "grep 'wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
    require => Class['maestro::package'],
    notify  => Service['maestro'],
  }

  file { "/etc/init.d/maestro":
    owner => "root",
    mode  => "0755",
    content => template("maestro/maestro.erb"),
    require => Class['maestro::package'],
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
    require => [File["/etc/init.d/maestro"], 
                Class["maestro::package", "maestro::maestro-postgres"]],
    subscribe => [File["${basedir}/conf/jetty.xml"], 
                  File["${basedir}/conf/security.properties"]],
  }  
}
