class maestro::lucee_demo_compositions(
  $use_sonar = undef,
  $use_archiva = undef,
  $ec2_key_id = '',
  $ec2_key = '',
  $archiva_host = "localhost",
  $archiva_port = "8082",
  $jenkins_host = "localhost",
  $jenkins_port = "8181",
  $sonar_host = "localhost",
  $sonar_port = "9000") {

  maestro::lucee_demo_composition { 'antwithivy': }
  maestro::lucee_demo_composition { 'centrepoint': }
  maestro::lucee_demo_composition { 'redmine': }
  maestro::lucee_demo_composition { 'wordpress': }
}
