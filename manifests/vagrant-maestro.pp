node default {
    $maestro_version = '4.12.0'

    notify { "using env MAESTRODEV_USERNAME=$maestrodev_username": 
       before => Class["maestro::maestro"];
    }

#    # Choose the following passwords as you wish
#    # note that admin password needs to validate against the password rules (letters+numbers by default)
#    $maestro_db_server_password = 'postgres' # Password on the Postgres admin user
#    $maestro_db_password        = 'maestr0'  # Password on the Maestro database user
#    $maestro_master_password    = 'maestr0'  # Password used to encrypt other passwords
#    $maestro_adminpassword      = 'maestr0'  # Initial Maestro administrator user password
#
#    # Use credentials provided by MaestroDev for trial / subscription
#    $repo = {
#      url      => 'https://repo.maestrodev.com/archiva/repository/all/',
#      username => $maestrodev_username,
#      password => $maestrodev_password,
#    }
#
#    # Java
#    file { "/etc/profile.d/set_java_home.sh":
#      ensure  => present,
#      content => 'export JAVA_HOME=/usr/lib/jvm/jre-openjdk-devel',
#      mode    => '0755',
#    } ->
#    exec { "/bin/sh /etc/profile": }
#    class { 'java': distribution => 'java-1.6.0-openjdk' }
#    package { "java-1.6.0-openjdk-devel": ensure => present}
#
#    # MAESTRO
#    include maestro
#    class { 'maestro::maestro':
#      package_type       => rpm,
#      repo               => $repo,
#      version            => $maestro_version,
#      admin_password     => $maestro_adminpassword,
#      master_password    => $maestro_master_password,
#      db_password        => $maestro_db_password,
#      #db_allowed_rules   => $db_allowed_rules,
#      db_server_password => $maestro_db_server_password,
#      jetty_forwarded    => true,
#      metrics_enabled    => true,
#    }
#
#    # ActiveMQ, with Stomp connector enabled
#    class { 'activemq': }
#    class { 'activemq::stomp': }
#
#    # demo compositions
#    class { 'maestro::lucee_demo_compositions': }
}
