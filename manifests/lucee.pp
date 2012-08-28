class maestro::lucee() {

  # We must make sure this file replaces the one installed
  # by the RPM package.
  file { '/etc/maestro_lucee.json':
    ensure => present,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/maestro/lucee/maestro_lucee.json',
    notify  => Service['maestro'],
    require => Class['maestro::package'],
    replace => false,
  }
}
