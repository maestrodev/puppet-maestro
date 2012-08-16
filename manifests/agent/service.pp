class maestro::agent::service {
   
  case $::operatingsystem {
    'Darwin': {
      include maestro::agent::service::darwin
    }
    default: {
      include maestro::agent::service::linux
    }
  }
  
}