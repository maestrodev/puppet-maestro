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
class maestro {
  include wget

  if ! defined(File['/usr/local/src']) {
    file {'/usr/local/src':
      ensure => directory,
    }
  }
}
