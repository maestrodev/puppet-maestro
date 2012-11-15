class maestro::agent::service::darwin {
  file { '/Library/LaunchDaemons/com.maestrodev.agent.plist':
    ensure  => present,
    content => template('maestro/agent/com.maestrodev.agent.plist.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'wheel',
    notify  => Service['maestro-agent'],
  } ->
  service { 'maestro-agent':
    ensure     => running,
    name       => 'com.maestrodev.agent',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    provider   => launchd,
    require    => [File['maestro-agent'], File[$maestro::agent::basedir], File[$maestro::params::agent_user_home]],
  }
}
