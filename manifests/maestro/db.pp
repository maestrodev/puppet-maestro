class maestro::maestro::db(
  $version             = $maestro::params::db_version,
  $password            = $maestro::params::db_server_password,
  $db_password         = $maestro::params::db_password,
  $allowed_rules       = $maestro::params::db_allowed_rules,
  $manage_package_repo = true,
  $enabled             = true) inherits maestro::params {

  if ($version == '' or $version == unset) {
    $version_real = $::postgres_default_version
  }
  else {
    $version_real = $version
    class { 'postgresql::params':
      version             => $version_real,
      manage_package_repo => $manage_package_repo,
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
      user     => $maestro::params::db_username,
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
