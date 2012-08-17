class maestro::lucee(
  $db_username = 'maestro',
  $db_password = 'maestro',
  $db_name = 'luceedb',
  $eui = false ) {

  file { '/etc/maestro_lucee.json':
    owner   => root,
    group   => root,
    content => template('maestro/lucee/maestro_lucee.json.erb'),
    notify  => Service['maestro'],
    require => Package['maestro'],
  }
}
