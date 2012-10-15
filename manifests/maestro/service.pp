class maestro::maestro::service(
  $enabled = $maestro::maestro::enabled,
  $db_password =  $maestro::maestro::db_password,
  $basedir =  $maestro::maestro::basedir,
  $port = $maestro::maestro::port,
  $ldap = $maestro::maestro::ldap) inherits maestro::params {
  
  file { "/etc/init.d/maestro":
    owner => "root",
    mode  => "0755",
    content => template("maestro/maestro.erb"),
    require => Class['maestro::maestro::package'],
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
      logoutput => "on_failure",
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
                Class["maestro::maestro::package", "maestro::maestro-postgres"]],
    subscribe => [File["${basedir}/conf/jetty.xml"], 
                  File["${basedir}/conf/security.properties"]],
  }
}