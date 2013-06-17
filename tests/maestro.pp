import 'common.pp'

$maestro_version   = '4.15.0'

# Maestro
class { 'maestro::maestro':
  repo          => $repo,
  version       => $version,
}
