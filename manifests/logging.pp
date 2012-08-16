class maestro::logging( $level = 'INFO' ) {

  augeas { 'maestro-logging':
    changes => [
      "set /files/etc/maestro_lucee.json/dict//entry[.='log']//entry[.='level']/string ${level}",
    ],
    incl    => '/etc/maestro_lucee.json',
    lens    => 'Json.lns',
    require => File['/etc/maestro_lucee.json'],
    notify  => Service['maestro'],
  }

}
