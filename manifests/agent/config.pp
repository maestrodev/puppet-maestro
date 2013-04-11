class maestro::agent::config(
  $srcdir = $maestro::agent::srcdir,
  $basedir = $maestro::agent::basedir,
  $agent_user_home = $maestro::agent::agent_user_home,
  $agent_user = $maestro::agent::agent_user,
  $agent_group = $maestro::agent::agent_group,
  $maxmemory = $maestro::agent::maxmemory,
  $timestamp_version = $maestro::agent::agent_version,
  $facter = $maestro::agent::facter,
  $stomp_host = $maestro::agent::stomp_host,
  $maven_servers = $maestro::agent::maven_servers,
  $agent_name = $maestro::agent::agent_name,
  $enable_jpda = $maestro::agent::enable_jpda,
  $support_email = $maestro::agent::support_email,
  $logging_level = $maestro::logging::level,
  $jmxport = $maestro::agent::jmxport,
  $rmi_server_hostname = $maestro::agent::rmi_server_hostname) {

  $wrapper = "${basedir}/conf/wrapper.conf"
  case $::operatingsystem {
    'Darwin': {
      $java_home ='/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home'
      $managehome = false
      $sed_suffix = " ''"
    }
    default: {
      $sed_suffix = ''
      $java_home='/usr/lib/jvm/java'
      $managehome = true
    }
  }

  file { 'maestro_agent.json':
    path    => "${agent_user_home}/conf/maestro_agent.json",
    content => template('maestro/agent/maestro_agent.json.erb'),
    owner   => $agent_user,
    group   => $agent_group,
    notify  => Service['maestro-agent'],
  } ->
  file { "${basedir}/conf/maestro_agent.json":
    ensure  => link,
    target  => "${agent_user_home}/conf/maestro_agent.json",
  }

  # prepare the augeas lens
  if !defined(File['/tmp/augeas']) {
    file { '/tmp/augeas': ensure => directory }
  }
  file { "/tmp/augeas/maestro-agent": ensure => directory } ->
  file { "/tmp/augeas/maestro-agent/properties.aug":
    source => "puppet:///modules/maestro/properties.aug"
  }->

  # adjust wrapper.conf
  augeas { "maestro-agent-wrapper-maxmemory":
    lens      => "Properties.lns",
    incl      => "${wrapper}",
    changes   => [
      "set wrapper.java.maxmemory ${maxmemory}",
    ],
    load_path => '/tmp/augeas/maestro-agent',
    notify    => Service['maestro-agent'],
  }

  $tmp_dir = "${agent_user_home}/tmp"
  notify{"Setting java.io.tmpdir=$tmp_dir for maestro agent":}
  file { "${agent_user_home}/tmp": 
    ensure => directory,
    owner   => $agent_user,
    group   => $agent_group,
  } ->
  augeas { "maestro-agent-wrapper-debug-and-tmpdir":
    lens      => "Properties.lns",
    incl      => "${wrapper}",
    changes   => [
      "set wrapper.java.additional.3 -XX:+HeapDumpOnOutOfMemoryError",
      "set wrapper.java.additional.4 -XX:HeapDumpPath=${agent_user_home}",
      "set wrapper.java.additional.5 -Djava.io.tmpdir=${tmp_dir}",
      "set wrapper.java.additional.6 -Dcom.sun.management.jmxremote=true",
      "set wrapper.java.additional.7 -Dcom.sun.management.jmxremote.port=${jmxport}",
      "set wrapper.java.additional.8 -Dcom.sun.management.jmxremote.authenticate=false",
      "set wrapper.java.additional.9 -Dcom.sun.management.jmxremote.ssl=false",
      "set wrapper.java.additional.10 -Djava.rmi.server.hostname=${rmi_server_hostname}",
    ],
    load_path => '/tmp/augeas/maestro-agent',
    notify    => Service['maestro-agent'],
  }

  if $enable_jpda {
      notify{"Enabling JPDA for maestro agent":}
      augeas { "maestro-agent-wrapper-jpda":
        lens      => "Properties.lns",
        incl      => "${wrapper}",
        changes   => [
          "set wrapper.java.additional.11 -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n",
        ],
        load_path => '/tmp/augeas/maestro-agent',
        notify    => Service['maestro-agent'],
      }
  }

  file { 'maestro-agent':
    path    => "${basedir}/bin/maestro_agent",
    owner   => $agent_user,
    group   => $agent_group,
    mode    => '0755',
    content => template('maestro/agent/maestro-agent.erb'),
  }

  file { "${srcdir}/maestro-agent.version":
    content => "${timestamp_version}\n",
  }


}
