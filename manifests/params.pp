class maestro::params(
  $user            = 'maestro',
  $group           = 'maestro',
  $user_home       = '/var/local/maestro',
  $agent_user      = 'maestro_agent',
  $agent_group     = 'maestro_agent',
  $agent_user_home = '/var/local/maestro-agent') {

  if ! defined(User[$user]) {
    user { $user:
      ensure     => present,
      home       => $maestro::params::user_home,
      managehome => true,
      shell      => '/bin/bash',
      system     => true,
      gid        => $maestro::params::group,
    }
  }

  if ! defined(Group[$group]) {
    group { $group:
      ensure => present,
      system => true,
    }
  }

}
