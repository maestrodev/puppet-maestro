class maestro::agent( $repo = $maestrodev_repo,
  $agent_version,
  $facter = true,
  $stomp_host = '',
  $maven_servers = '',
  $basedir = '/usr/local/maestro-agent',
  $agent_name = 'maestro_agent',
  $maxmemory = '128') inherits maestro::params {
  
  $srcdir = "/usr/local/src"

  # TODO: put this in a library so it can be reused
  # If the version is a Maven snapshot, transform the base version to it's
  # SNAPSHOT indicator
  if $agent_version =~ /^(.*)-[0-9]{8}\.[0-9]{6}-[0-9]+$/ {
    $base_version = "${1}-SNAPSHOT"
    $timestamp_version = $agent_version
  } else {
    $base_version = $agent_version
    $timestamp_version = $agent_version # version is a release
  }

  # Note that later pieces assume basedir ends in maestro-agent, would need a
  # different approach

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

  if ! defined(User[$agent_user]) {

    if $::rvm_installed == 'true' { # important to compare to string 'true'
      $groups = ['root', 'rvm']
    } elsif $::rvm_installed == 'false' {
      $groups = "root"
    } else {
      $msg = "Fact rvm_installed not defined or not true|false: '${::rvm_installed}'. Ensure puppet is run with --pluginsync"
      notify { $msg : }
      warning($msg)
      $groups = "root"
    }

    group { $agent_group:
      ensure => present,
    } ->
    user { $agent_user:
      ensure     => present,
      managehome => $managehome,
      home       => $agent_user_home,
      shell      => "/bin/bash",
      gid        => $agent_group,
      groups     => $groups,
      system     => true,
    }
  }

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  $wrapper = "$basedir/conf/wrapper.conf"

  wget::authfetch { "fetch-agent":
    user        => $repo['username'],
    password    => $repo['password'],
    source      => "${repo['url']}/com/maestrodev/lucee/agent/${base_version}/agent-${timestamp_version}-bin.tar.gz",
    destination => "$srcdir/agent-${timestamp_version}-bin.tar.gz",
  } ->
  exec {"rm -rf $basedir":
     unless => "egrep \"^${timestamp_version}$\" $srcdir/maestro-agent.version",
  } ->
  exec { "agent":

    command => "tar zxf $srcdir/agent-${timestamp_version}-bin.tar.gz && chown -R ${agent_user}:${agent_group} maestro-agent ${agent_user_home}",
    creates => "${basedir}/lib",
    cwd     => '/usr/local', # TODO use $basedir instead of hardcoded
    path    => "/bin/:/usr/bin:/usr/sbin",
    require => [User[$agent_user],File[$agent_user_home]],
    notify  => Service["maestro-agent"],
  } ->
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
  } ->
  exec { 'maestro-agent-memory-max':
    command => "sed -i${sed_suffix} 's/^#wrapper\\.java\\.maxmemory=.*$/wrapper\\.java\\.maxmemory=${maxmemory}/' ${wrapper}",
    unless  => "grep 'wrapper.java.maxmemory=${maxmemory}' ${wrapper}",
    notify  => Service['maestro-agent'],
  } ->
  file { "maestro-agent":
    path    => "${basedir}/bin/maestro_agent",
    owner   => $agent_user,
    group   => $agent_group,
    mode    => 755,
    content => template("maestro/agent/maestro-agent.erb"),
  }

  exec { "echo $timestamp_version >$srcdir/maestro-agent.version":
    require => Exec[agent],
  } ->
  # Touch the installation package even if current, so that it isn't deleted
  exec { "touch $srcdir/agent-${timestamp_version}-bin.tar.gz":
  }# ->
  #tidy { "tidy-agents":
    #age => "1d",
    #matches => "agent-*",
    #recurse => true,
    #path => $srcdir,
  #}

  file { "/var/local":
    ensure  => directory,
  }
  file { ["${agent_user_home}","${agent_user_home}/logs","${agent_user_home}/conf"]:
    ensure  => directory,
    owner   => $agent_user,
    group   => $agent_group,
    require => File[ "/var/local" ],
  }

  file { $basedir:
    ensure  => directory,
    owner   => $agent_user,
    group   => $agent_group,
    require => Exec[agent],
  } ->
  file { "${basedir}/logs":
    ensure  => link,
    target  => "${agent_user_home}/logs",
    owner   => $agent_user,
    group   => $agent_group,
    force   => true,
  } 
  
  include maestro::agent::service

}
