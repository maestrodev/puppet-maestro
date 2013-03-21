class maestro::lucee(
  $config_dir  = '/var/local/maestro/conf',
  $agent_auto_activate = false,
  $username = $maestro::lucee::db::username,
  $password = $maestro::lucee::db::password,
  $type     = $maestro::lucee::db::type,
  $host     = $maestro::lucee::db::host,
  $port     = $maestro::lucee::db::port,
  $logging_level = $maestro::logging::level,
  $database = $maestro::lucee::db::database,
  $metrics_enabled = false) {

  # The $demo is set by the node.pp (or equiv) and is new way of detecting whether demo enabled.
  # The 'or' is so existing code will continue to function - remove when maestro::lucee::demo_compositions is gone
  if $demo or defined (Class['maestro::lucee::demo_compositions']) {
    $is_demo = true
  }
  else {
    $is_demo = false
  }

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
