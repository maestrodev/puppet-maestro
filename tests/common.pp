notify { "using MAESTRODEV_USERNAME=$maestrodev_username": }

# Use credentials provided by MaestroDev for trial / subscription
$repo = {
  url      => 'https://repo.maestrodev.com/archiva/repository/all/',
  username => $maestrodev_username,
  password => $maestrodev_password,
}

# Java
class { 'java': package => 'java-1.6.0-openjdk-devel' }

firewall { '900 enable ssh':
  action => accept,
  dport => "22",
  proto => "tcp",
}

