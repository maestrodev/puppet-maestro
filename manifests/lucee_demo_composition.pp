define maestro::lucee_demo_composition(
  $use_sonar = $maestro::lucee_demo_compositions::use_sonar,
  $use_archiva = $maestro::lucee_demo_compositions::use_archiva,
  $use_irc = false,
  $ec2_key_id = $maestro::lucee_demo_compositions::ec2_key_id,
  $ec2_key = $maestro::lucee_demo_compositions::ec2_key,
  $archiva_host = $maestro::lucee_demo_compositions::archiva_host,
  $archiva_port = $maestro::lucee_demo_compositions::archiva_port,
  $jenkins_host = $maestro::lucee_demo_compositions::jenkins_host,
  $jenkins_port = $maestro::lucee_demo_compositions::jenkins_port,
  $sonar_host = $maestro::lucee_demo_compositions::sonar_host,
  $sonar_port = $maestro::lucee_demo_compositions::sonar_port) {

  if defined(Class["agent_module"]) {
    $agent_home_dir = "${agent_module::run_as_home_real}"
  } else {
    $agent_home_dir = "/var/local/maestro-agent"
  }

  if $use_sonar == undef {
    $sonar = defined(Service['sonar'])
  } else {
    $sonar = $use_sonar
  }
  if $use_archiva == undef {
    $archiva = defined(Service['archiva'])
  } else {
    $archiva = $use_archiva
  }

  if ($archiva) {
    $goal = 'deploy'
  } else {
    $goal = 'install'
  }

  file { "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/${name}.json":
    owner   => $maestro::maestro::run_as,
    group   => $maestro::maestro::run_as,
    mode    => 644,
    before  => Service['maestro'],
    require => Exec['maestro'],
    content => template("maestro/lucee/demo/${name}.json.erb"),
  }
}
