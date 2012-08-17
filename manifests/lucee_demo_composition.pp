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
  $sonar_port = $maestro::lucee_demo_compositions::sonar_port,
  $working_copy_dir = $maestro::lucee_demo_compositions::working_copy_dir,
  $demo_keypair = $maestro::lucee_demo_compositions::demo_keypair) {

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
    owner   => $maestro::params::user,
    group   => $maestro::params::group,
    mode    => 644,
    before  => Service['maestro'],
    require => Package['maestro'],
    content => template("maestro/lucee/demo/${name}.json.erb"),
  }
}
