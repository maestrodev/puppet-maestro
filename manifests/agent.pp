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
  $agent_version,
  $repo = $maestrodev_repo,
  $package_type = 'tarball',
  $facter = true,
  $stomp_host = '',
  $maven_servers = '',
  $agent_name = 'maestro_agent',
  $maxmemory = '128') inherits maestro::params {

  $basedir = '/usr/local/maestro-agent'
  $srcdir = '/usr/local/src'


  # Note that later pieces assume basedir ends in maestro-agent, would need a
  # different approach

  if ! defined(User[$maestro::params::agent_user]) {

    $admin_group = $::osfamily ? { 'Darwin' => 'admin', default => 'root' }
    
    if $::rvm_installed == 'true' { # important to compare to string 'true'
      $groups = [$admin_group, 'rvm']
    } elsif $::rvm_installed == 'false' {
      $groups = $admin_group
    } else {
      $msg = "Fact rvm_installed not defined or not true|false: '${::rvm_installed}'. Ensure puppet is run with --pluginsync"
      notify { $msg : }
      warning($msg)
      $groups = $admin_group
    }

    if ! defined(Group[$maestro::params::agent_group]) {
      group { $maestro::params::agent_group:
        ensure => present,
        before => User[$maestro::params::agent_user],
      }
    }

    if $::osfamily == 'Darwin' {
      # User creation is broken in Mountain Lion
      # user { $maestro::params::agent_user:
      #  ensure     => present,
      #  home       => $maestro::params::agent_user_home,
      #  shell      => '/bin/bash',
      #  gid        => $maestro::params::agent_group,
      #  groups     => $groups,
      #  before     => Class['maestro::agent::package'],
      #}
    } 
    else
    {
      user { $maestro::params::agent_user:
        ensure     => present,
        managehome => true,
        home       => $maestro::params::agent_user_home,
        shell      => '/bin/bash',
        gid        => $maestro::params::agent_group,
        groups     => $groups,
        system     => true,
        before     => Class['maestro::agent::package'],
      }
    }
  }

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  class { 'maestro::agent::package': } -> class { 'maestro::agent::config': } -> class { 'maestro::agent::service': }

}
