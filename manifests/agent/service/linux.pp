class maestro::agent::service::linux {
  file { '/etc/init.d/maestro-agent':
    ensure  => link,
    target  => "${maestro::agent::basedir}/bin/maestro_agent",
    notify  => Service['maestro-agent'],
    require => File['maestro-agent'],
  } ->
  service { 'maestro-agent':
    ensure  => running,
    enable  => true,
    require => [File[$maestro::agent::basedir], File[$maestro::params::agent_user_home],Package['java']],
  }
}
