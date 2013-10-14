class maestro::lucee(
  $config_dir  = '/var/local/maestro/conf',
  $agent_auto_activate = false,
  $lucee_password      = $maestro::maestro::lucee_password,
  $lucee_username      = $maestro::maestro::lucee_username,
  $username            = $maestro::lucee::db::username,
  $password            = $maestro::lucee::db::password,
  $type                = $maestro::lucee::db::type,
  $host                = $maestro::lucee::db::host,
  $port                = $maestro::lucee::db::port,
  $messenger_debugging = false,
  $logging_level       = $maestro::logging::level,
  $database            = $maestro::lucee::db::database,
  $metrics_enabled     = false,
  $is_demo             = false) inherits maestro::lucee::db {

  # We must make sure this file replaces the one installed
  # by the RPM package.

  file { "${config_dir}/maestro_lucee.json":
    ensure  => present,
    owner   => root,
    group   => root,
    content => template('maestro/lucee/maestro_lucee.json.erb'),
    notify  => Service['maestro'],
    require => Class['maestro::package'],
  }

  # Remove legacy file.
  if $config_dir != '/etc' {
    file { '/etc/maestro_lucee.json':
      ensure => absent,
      require => Class['maestro::package'],
    }
  }
}
