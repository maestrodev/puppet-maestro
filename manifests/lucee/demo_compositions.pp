class maestro::lucee::demo_compositions(
  $use_sonar = undef,
  $use_archiva = undef,
  $ec2_key_id = '',
  $ec2_key = '',
  $archiva_host = "localhost",
  $archiva_port = "8082",
  $jenkins_host = "localhost",
  $jenkins_port = "8181",
  $sonar_host = "localhost",
  $sonar_port = "9000",
  $working_copy_dir = "/var/local/maestro-agent/wc",
  $demo_keypair = "/var/local/maestro-agent/.ssh/lucee-demo-keypair.pem") {

  maestro::lucee::demo_composition { 'antwithivy': }
  maestro::lucee::demo_composition { 'centrepoint': }
  maestro::lucee::demo_composition { 'redmine': }
  maestro::lucee::demo_composition { 'wordpress': }
  maestro::lucee::demo_composition { 'android': }
}
