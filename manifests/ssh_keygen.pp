class maestro::ssh_keygen( $home = '/home/maestro', $user = 'maestro' ) {
  exec { "ssh-keygen -f \"${home}/.ssh/id_rsa\" -N \"\" -C \"maestro automation key\"":
    user    => $user,
    creates => "${home}/.ssh/id_rsa",
    path    => '/usr/bin',
  }
}
