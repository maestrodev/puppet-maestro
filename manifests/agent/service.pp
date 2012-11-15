class maestro::agent::service {

  case $::kernel {
    'Darwin': {
      include maestro::agent::service::darwin
    }
    'Linux': {
      include maestro::agent::service::linux
    }
    default: {
      fail('Unsupported operating system')
    }
  }

}