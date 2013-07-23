class maestro::maestro::db(
  $version             = $maestro::maestro::db_version,
  $password            = $maestro::maestro::db_server_password,
  $db_password         = $maestro::maestro::db_password,
  $allowed_rules       = $maestro::maestro::db_allowed_rules,
  $manage_package_repo = true,
  $enabled             = true) {

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
      user     => 'maestro',
      password => $db_password,
      require => Class['postgresql::server'],
    }

    postgresql::db{ 'maestro': }
    postgresql::db{ 'luceedb': }
    postgresql::db{ 'users': }

    # LDAP default system admin user, add permissions
    if !empty($maestro::maestro::ldap) {
      exec { 'insert-ldap-default-admin' :
        command     => "psql -h localhost -d maestro -U maestro -c \
        \"delete from userassignment where id=-1; insert into userassignment values(-1, '*', '${maestro::maestro::ldap['admin_user']}', (select id from role where name='System Administrator') );\"",
        unless      => "psql -h localhost -d maestro -U maestro -c \
        \"select username from userassignment where id=-1;\" | grep '${maestro::maestro::ldap['admin_user']}'",
        environment => "PGPASSWORD=${db_password}",
        path        => '/bin/:/usr/bin',
        logoutput   => true,
        require     => Service['postgresqld'],
      }
    }
  }
  else {
    service { 'postgresql':
      ensure    => stopped,
      enable    => false,
      hasstatus => true,
    }
  }

}
