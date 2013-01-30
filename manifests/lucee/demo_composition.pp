define maestro::lucee::demo_composition(
  $use_sonar        = $maestro::lucee::demo_compositions::use_sonar,
  $use_archiva      = $maestro::lucee::demo_compositions::use_archiva,
  $use_irc          = false,
  $ec2_key_id       = $maestro::lucee::demo_compositions::ec2_key_id,
  $ec2_key          = $maestro::lucee::demo_compositions::ec2_key,
  $archiva_host     = $maestro::lucee::demo_compositions::archiva_host,
  $archiva_port     = $maestro::lucee::demo_compositions::archiva_port,
  $jenkins_host     = $maestro::lucee::demo_compositions::jenkins_host,
  $jenkins_port     = $maestro::lucee::demo_compositions::jenkins_port,
  $jenkins_context_path = $maestro::lucee::demo_compositions::jenkins_context_path,
  $sonar_host       = $maestro::lucee::demo_compositions::sonar_host,
  $sonar_port       = $maestro::lucee::demo_compositions::sonar_port,
  $sonar_context_path = $maestro::lucee::demo_compositions::sonar_context_path,
  $working_copy_dir = $maestro::lucee::demo_compositions::working_copy_dir,
  $demo_keypair     = $maestro::lucee::demo_compositions::demo_keypair) {

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

  # until the directory is included in LuCEE
  if !defined(File["${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/disabled"]) {
    file { "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/disabled":
      ensure  => directory,
      owner   => $maestro::params::user,
      group   => $maestro::params::group,
      mode    => '0644',
      before  => Service['maestro'],
      require => File['/etc/maestro_lucee.json'],
    }
  }

  file { "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/${name}.json":
    owner   => $maestro::params::user,
    group   => $maestro::params::group,
    mode    => '0644',
    before  => Service['maestro'],
    require => File['/etc/maestro_lucee.json'],
    content => template("maestro/lucee/demo/${name}.json.erb"),
  }
}
