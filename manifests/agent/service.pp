class maestro::agent::service {

  case $::osfamily {
    'Darwin': {
      include maestro::agent::service::darwin
    }
    'RedHat', 'Debian': {
      include maestro::agent::service::linux
    }
    default: {
      fail('Unsupported operating system')
    }
  }

}
