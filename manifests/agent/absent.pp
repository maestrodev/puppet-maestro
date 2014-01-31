class maestro::agent::absent(
  $version = '0.1.0',
  $user = 'agent',
  $user_home = undef,
  $basedir = '/var/maestro-agent') {

  service { 'maestro-agent':
    ensure => stopped,
    enable => false,
  }

  if ! defined(User[$user]) {
    if $user_home == undef {
      $user_home_real = "/home/$user"
    } else {
      $user_home_real = $user_home
    }

    user { $user:
      ensure     => absent,
      managehome => $::operatingsystem ? { 'Darwin' => undef, default => true },
      require    => Service['maestro-agent'],
    } ->
    file { $user_home_real:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }

  package { 'maestro-agent':
    ensure  => absent,
    require => Service['maestro-agent'],
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
