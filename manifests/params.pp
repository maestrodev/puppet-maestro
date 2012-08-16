class maestro::params(
  $user = 'maestro',
  $group = $user,
  $user_home = "/var/local/$user", 
  $agent_user = "maestro_agent",
  $agent_group = $agent_user,
  $agent_user_home = "/var/local/maestro-agent") {
  
  if ! defined(User[$user]) {
    user { $user:
      ensure     => present,
      home       => $user_home,
      managehome => true,
      shell      => "/bin/bash",
      system     => true,
      gid        => $group,
    }
  }

  if ! defined(Group[$group]) {
    group { $group:
      ensure     => present,
      system     => true,
    }
  }
}