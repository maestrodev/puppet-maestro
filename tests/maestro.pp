import 'common.pp'

$maestro_version   = '4.15.0'

include activemq
include activemq::stomp

# Maestro
class { 'maestro::maestro':
  repo               => $repo,
  version            => $version,
  admin_password     => "admin",
  master_password    => "admin",
  db_server_password => "admin",
  db_password        => "admin",
  enable_jpda        => true,
}

Package['java'] -> Service['activemq']
Package['java'] -> Service['maestro']
