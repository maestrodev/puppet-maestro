# Class: maestro
#
# This module manages maestro
#
# Parameters:
#
# Actions:
#
# Requires:
#
# [Remember: No empty lines between comments and class definition]
class maestro($run_as = 'maestro', $run_as_home = "UNSET" ) {
  
  include wget

  if ! defined(User[$run_as]) {
    if $run_as_home == "UNSET" {
      $homedir = "/home/${run_as}"
    }
    else {
      $homedir = $run_as_home
    }

    user { $run_as:
      ensure     => present,
      home       => $homedir,
      managehome => true,
      shell      => "/bin/bash",
      system     => true,
      gid        => $run_as,
    }
  }

  if ! defined(Group[$run_as]) {
    group { $run_as:
      ensure     => present,
      system     => true,
    }
  }
}
