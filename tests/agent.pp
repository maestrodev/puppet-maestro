import 'common.pp'

$agent_version   = '1.6.0'

# Agent
class { 'maestro::agent':
  repo                => $repo,
  agent_version       => $agent_version,
  rmi_server_hostname => "10.42.42.50",
}
Package['java'] -> Service['maestro-agent']

# Firewall rule to open up JMX port on our vagrant box
firewall { '900 enable jmx':
  action => accept,
  dport => $maestro::agent::jmxport,
  proto => "tcp",
}
