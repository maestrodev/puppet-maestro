class maestro::agent::service::linux(
  $enabled     = $maestro::maestro::enabled
) {
  $ensure_service = $enabled ? { true => running, false => stopped, }
  file { '/etc/init.d/maestro-agent':
    ensure  => link,
    target  => "${maestro::agent::basedir}/bin/maestro_agent",
    notify  => Service['maestro-agent'],
    require => File['maestro-agent'],
  } ->
  service { 'maestro-agent':
    ensure  => $ensure_service,
    enable  => $enabled,
    require => [File[$maestro::agent::basedir], File[$maestro::params::agent_user_home],Package['java']],
  }
}
