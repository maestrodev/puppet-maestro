# This class is used to install and configure the Maestro agent.
#
#
# ==Parameters
#
# [repo]  A hash containing the artifact repository URL and credentials.
# [package_type] Selects the type of package to use for the install. Either rpm, or tarball.
# [agent_version] The version to install
# [facter] Indicates if the agent should use facter
# [stomp_host] the hostname or IP address of the stomp server
# [maven_servers] a list of maven servers
# [agent_name] the name this agent should identify itself with on the Maestro server
# [maxmemory] the wrapper.java.maxmemory setting to configure in the wrapper.
#
class maestro::agent( 
  $repo = $maestrodev_repo,
  $package_type = 'tarball',
  $agent_version,
  $facter = true,
  $stomp_host = '',
  $maven_servers = '',
  $agent_name = 'maestro_agent',
  $maxmemory = '128') inherits maestro::params {
  
  $basedir = "/usr/local/maestro-agent"
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
  
  class { 'maestro::agent::package': } -> class { 'maestro::agent::config': } -> class { 'maestro::agent::service': }

}
