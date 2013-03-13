node default {
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
    file { "/etc/profile.d/set_java_home.sh":
      ensure  => present,
      content => 'export JAVA_HOME=/usr/lib/jvm/jre-openjdk',
      mode    => '0755',
    } ->
    exec { "/bin/sh /etc/profile": }
    class { 'java': distribution => 'java-1.6.0-openjdk' }
    package { "java-1.6.0-openjdk-devel": ensure => present}

    # Agent
    class { 'maestro::agent':
      repo           => $repo,
      agent_version  => $agent_version,
    }
}
