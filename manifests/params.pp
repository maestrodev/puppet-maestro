class maestro::params(
  $enabled         = true,
  $user            = 'maestro',
  $group           = 'maestro',
  $user_home       = '/var/local/maestro',
  $agent_user      = 'maestro_agent',
  $agent_group     = 'maestro_agent',
  $agent_user_home = '/var/local/maestro-agent',
  $repo            = undef,
  $logging_level   = 'INFO',
  $lucee_password  = 'maestro',
  $lucee_username  = 'maestro',

  $db_server_password = $maestro_db_server_password,
  $db_password        = $maestro_db_password,
  $db_version         = undef,
  $db_allowed_rules   = []) {

  $srcdir = '/usr/local/src'

  Exec {
    path => '/bin/:/usr/bin:/usr/sbin',
  }

}
