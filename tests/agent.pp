$agent_version   = '1.6.0'

notify { "using MAESTRODEV_USERNAME=$maestrodev_username": 
   before => Class["maestro::agent"];
}

# Use credentials provided by MaestroDev for trial / subscription
$repo = {
  url      => 'https://repo.maestrodev.com/archiva/repository/all/',
  username => $maestrodev_username,
  password => $maestrodev_password,
}

# Java
class { 'java': package => 'java-1.6.0-openjdk-devel' }

# Agent
class { 'maestro::agent':
  repo                => $repo,
  agent_version       => $agent_version,
  rmi_server_hostname => "10.42.42.50",
}

# Firewall rule to open up JMX port on our vagrant box
firewall { '900 enable ssh':
  action => accept,
  dport => "22",
  proto => "tcp",
}
firewall { '900 enable jmx':
  action => accept,
  dport => $maestro::agent::jmxport,
  proto => "tcp",
}
