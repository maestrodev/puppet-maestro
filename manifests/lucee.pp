class maestro::lucee(
  $db_username = 'maestro',
  $db_password = 'maestro',
  $db_name = 'luceedb',
  $is_demo = false,
  $log_level = "INFO",
  $eui = false ) {

  file { '/etc/maestro_lucee.json':
    owner   => root,
    group   => root,
    content => template('maestro/lucee/maestro_lucee.json.erb'),
    notify  => Service['maestro'],
    require => Exec['maestro'],
  }
}
