class maestro::lucee($agent_auto_activate = false,
  $username = 'maestro',
  $password = 'maestro',
  $type = 'postgres',
  $host = 'localhost',
  $port = 5432,
  $database = 'luceedb') {

  # We must make sure this file replaces the one installed
  # by the RPM package.

  file { '/etc/maestro_lucee.json':
    ensure => present,
    owner   => root,
    group   => root,
    content =>  template("maestro/lucee/maestro_lucee.json.erb"),
    notify  => Service['maestro'],
    require => Class['maestro::package'],
  }
}
