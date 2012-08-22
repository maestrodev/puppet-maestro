class maestro::lucee() {

  # Create the /etc/maestro_lucee.json the first time only
  file { '/etc/maestro_lucee.json':
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/maestro/lucee/maestro_lucee.json',
    notify  => Service['maestro'],
    require => Exec['maestro'],
    replace => false,
  }
}
