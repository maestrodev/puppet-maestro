class maestro::agent::absent(
  $version = '0.1.0',
  $user = 'agent',
  $user_home = "/home/$user",
  $basedir = '/var/maestro-agent') {

  service { 'maestro-agent':
   enable => false,
   ensure => stopped,
  }

  if ! defined(User[$user]) {

    user { $user:
      ensure     => absent,
      managehome => true,
      require    => Service['maestro-agent'],
    } ->
    file { $user_home:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }

  file { ['/root/.gemrc', "/usr/local/src/agent-${version}.tar.gz", '/usr/local/src/maestro-agent.version', '/etc/init.d/maestro-agent']:
    ensure  => absent,
    require => Service['maestro-agent'],
  } ->
  file { $basedir:
    ensure  => absent,
    recurse => true,
    force   => true,
  }
}
