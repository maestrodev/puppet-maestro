class maestro::maestro::config(
    $ldap = $maestro::maestro::ldap, 
    $master_password = $maestro::maestro::master_password,
    $mail_from = $maestro::maestro::mail_from,
    $basedir = $maestro::maestro::basedir) inherits maestro::params {
      
      File {
        owner => $user,
        group => $group,
      }
      # Configure Maestro
      file { "${basedir}/conf/security.properties":
        mode    =>  "0644",
        content =>  template("maestro/security.properties.erb"),
        require => File["${basedir}/conf"],
      }
}
