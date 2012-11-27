class maestro::params(
  $user            = 'maestro',
  $group           = 'maestro',
  $user_home       = '/var/local/maestro',
  $agent_user      = 'maestro_agent',
  $agent_group     = 'maestro_agent',
  $agent_user_home = '/var/local/maestro-agent') {


  if ! defined(User[$user]) {

    if $::osfamily == 'Darwin' {
      # User creation is broken in Mountain Lion 
      #user { $user:
      #  ensure => present,
      #  home   => $user_home,
      #  shell  => '/bin/bash',
      #  gid    => $group,
      #  require => Group[$group],
      #}
    }
    else 
    {
      user { $user:
        ensure     => present,
        home       => $user_home,
        managehome => true,
        shell      => '/bin/bash',
        system     => true,
        gid        => $group,
        require    => Group[$group],
      }
    }
  }

  if ! defined(Group[$group]) {
    group { $group:
      ensure => present,
      system => true,
    }
  }

}

