class maestro::maestro-postgres(
  $version = '',
  $password,
  $db_password,
  $datadir = '/var/lib/pgsql/data',
  $allowed_rules = [],
  $enabled = true) {

  # $version = case $operatingsystem {
  #   centos: {
  #     case $operatingsystemrelease {
  #       5.4: { '84' }
  #       5.5: { '' }
  #     }
  #   }
  # }

  class { 'postgres' :
    version  => $version,
    password => $password,
    datadir  => $datadir,
  }

  if $enabled {
    # csanchez: TODO remove after the postgres user password is properly set.
    postgres::user { "postgres": passwd => $password, }

    postgres::initdb{ "host":
      require => Package["postgresql${version}"],
    } ->
    postgres::hba { "host": allowedrules => $allowed_rules } ->
    postgres::config { "host" :listen => "*" } ->
    postgres::enable { "host": require => Postgres::Config["host"], } ->
    postgres::user { "maestro": passwd => $db_password, } ->
    postgres::createdb { "maestro":owner=> "maestro", require => Postgres::Createuser["maestro"], } ->
    postgres::createdb { "luceedb":owner=> "maestro", require => Postgres::Createuser["maestro"], } ->
    postgres::createdb { "users":owner=> "maestro", require => Postgres::Createuser["maestro"], } ->
    postgres::createdb { "continuum":owner=> "maestro", require => Postgres::Createuser["maestro"], } ->
    postgres::createdb { "archiva":owner=> "maestro", require => Postgres::Createuser["maestro"], } ->
    postgres::createdb { "sonar":owner=> "maestro", require => Postgres::Createuser["maestro"], }

  }
  else {
    service { postgresql:
      ensure => stopped,
      enable => false,
      hasstatus => true,
    }
  }
}
