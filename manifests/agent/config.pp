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
  $agent_name = $maestro::agent::agent_name) {
  
  $wrapper = "$basedir/conf/wrapper.conf"
  case $::operatingsystem {
     'Darwin': {
       $java_home="/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home"
       $managehome = false
       $sed_suffix = " ''"
     }
     default: {
       $sed_suffix = ""
       $java_home="/usr/lib/jvm/java"
       $managehome = true
     }
   }
  
  file { "maestro_agent.json":
    path    => "${agent_user_home}/conf/maestro_agent.json",
    content => template("maestro/agent/maestro_agent.json.erb"),
    owner   => $agent_user,
    group   => $agent_group,
    notify  => Service["maestro-agent"],
  } ->
  file { "${basedir}/conf/maestro_agent.json":
    ensure  => link,
    target  => "${agent_user_home}/conf/maestro_agent.json",
  }
  
  exec { 'maestro-agent-memory-max':
    command => "sed -i${sed_suffix} 's/^#wrapper\\.java\\.maxmemory=.*$/wrapper\\.java\\.maxmemory=${maxmemory}/' ${wrapper}",
    unless  => "egrep '^wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
    notify  => Service['maestro-agent'],
  }
  
  file { "maestro-agent":
    path    => "${basedir}/bin/maestro_agent",
    owner   => $agent_user,
    group   => $agent_group,
    mode    => 755,
    content => template("maestro/agent/maestro-agent.erb"),
  }
  
  file { "${srcdir}/maestro-agent.version":
    content => "${timestamp_version}\n",
  }

  
}