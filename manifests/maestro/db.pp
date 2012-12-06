class maestro::maestro::db(
  $version       = $maestro::maestro::db_version,
  $password      = $maestro::maestro::db_server_password,
  $db_password   = $maestro::maestro::db_password,
  $allowed_rules = $maestro::maestro::db_allowed_rules,
  $enabled       = true) {

  if ($version == '' or $version == unset) {
    $version_real = $::postgres_default_version
  }
  else {
    $version_real = $version
    yumrepo { 'postgresql-repo':
      name     => "postgresql-${version_real}",
      baseurl  => "http://yum.postgresql.org/${version_real}/redhat/rhel-\$releasever-\$basearch",
      descr    => "Postgresql ${version_real} Yum Repo",
      enabled  => 1,
      gpgcheck => 0,
      before => Class['postgresql::server'],
    }
    
    class { 'postgresql::params':
      version             => $version_real,
      manage_package_repo => false,
      package_source      => 'yum.postgresql.org',
    }
    Class ['postgresql::params'] -> Class['postgresql::server']
  }
  class { 'postgresql::server':

    config_hash => {
      'ip_mask_deny_postgres_user' => '0.0.0.0/32',
      'ip_mask_allow_all_users'    => '0.0.0.0/0',
      'listen_addresses'           => '*',
      'manage_redhat_firewall'     => false,
      'postgres_password'          => $password,
      'ipv4acls'                   => $allowed_rules
    },
  }


  if $enabled {

    Postgresql::Db {
      user     => 'maestro',
      password => $db_password,
      require => Class['postgresql::server'],
    }

    postgresql::db{ 'maestro': }
    postgresql::db{ 'luceedb': }
    postgresql::db{ 'users': }

  }
  else {
    service { 'postgresql':
      ensure    => stopped,
      enable    => false,
      hasstatus => true,
    }
  }
}
