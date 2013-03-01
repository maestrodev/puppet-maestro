class maestro::lucee(
  $agent_auto_activate = false,
  $username = 'maestro',
  $password = 'maestro',
  $type     = 'postgres',
  $host     = 'localhost',
  $port     = 5432,
  $database = 'luceedb',
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

  file { '/etc/maestro_lucee.json':
    ensure  => present,
    owner   => root,
    group   => root,
    content => template('maestro/lucee/maestro_lucee.json.erb'),
    notify  => Service['maestro'],
    require => Class['maestro::package'],
  }
}
