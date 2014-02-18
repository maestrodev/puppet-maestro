# This class is used to install and configure the Maestro agent.
#
#
# ==Parameters
#
# [repo]  A hash containing the artifact repository URL and credentials.
# [package_type] Selects the type of package to use for the install. Either rpm, or tarball.
# [enabled] Enables/disables the service
# [agent_version] The version to install
# [facter] Indicates if the agent should use facter
# [stomp_host] the hostname or IP address of the stomp server
# [maven_servers] a list of maven servers
# [agent_name] the name this agent should identify itself with on the Maestro server
# [maxmemory] the wrapper.java.maxmemory setting to configure in the wrapper.
# [enable_jpda] A boolean indicating whether or not we want to enable JPDA
# [support_email] An email address to send any fatal error logs to from the # agent
# [jmxport] The port number the JMX server will listen on (default 9002)
# [rmi_server_hostname] The ip address the JMX server will listen on (default $ipaddress)
#
class maestro::agent(
  $agent_version,
  $repo = $maestro::params::repo,
  $package_type = 'tarball',
  $enabled = true,
  $facter = true,
  $stomp_host = '',
  $maven_servers = '',
  $agent_name = 'maestro_agent',
  $maxmemory = '128',
  $enable_jpda = false,
  $support_email = "support@maestrodev.com",
  $jmxremote = false,
  $jmxport = '9002',
  $rmi_server_hostname = $ipaddress) inherits maestro::params {

  $basedir = '/usr/local/maestro-agent'


  # Note that later pieces assume basedir ends in maestro-agent, would need a
  # different approach

  if ! defined(User[$maestro::params::agent_user]) {

    $admin_group = $::osfamily ? { 'Darwin' => 'admin', default => 'root' }

    if ! defined(Group[$maestro::params::agent_group]) {
      group { $maestro::params::agent_group:
        ensure => present,
      }
    }

    if $::operatingsystem == 'Darwin' {
      # User creation is broken in Mountain Lion
      # user { $maestro::params::agent_user:
      #  ensure     => present,
      #  home       => $maestro::params::agent_user_home,
      #  shell      => '/bin/bash',
      #  gid        => $maestro::params::agent_group,
      #  groups     => $admin_group,
      #  before     => Class['maestro::agent::package'],
      #}
    } 
    else
    {
      user { $maestro::params::agent_user:
        ensure     => present,
        managehome => $::operatingsystem ? { 'Darwin' => undef, default => true },
        home       => $maestro::params::agent_user_home,
        shell      => '/bin/bash',
        gid        => $maestro::params::agent_group,
        groups     => $admin_group,
        system     => true,
        before     => Class['maestro::agent::package'],
      }
    }
  }

  class { 'maestro::agent::package': } -> class { 'maestro::agent::config': } -> class { 'maestro::agent::service': }

}
