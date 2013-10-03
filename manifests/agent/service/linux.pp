class maestro::agent::service::linux(
  $enabled     = $maestro::agent::enabled
) {

  # older agents
  if versioncmp($maestro::agent::agent_version, '2.1.0') < 0 {

    file { '/etc/init.d/maestro-agent':
      ensure  => link,
      target  => "${maestro::agent::basedir}/bin/maestro_agent",
      notify  => Service['maestro-agent'],
      require => File['maestro-agent'],
    }
  }

  service { 'maestro-agent':
    ensure  => $enabled ? { true => running, false => stopped },
    enable  => $enabled,
    require => [Anchor['maestro::agent::package::end'], Package['java']],
  }
}
