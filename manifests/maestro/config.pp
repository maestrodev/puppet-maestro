class maestro::maestro::config(
    $ldap = $maestro::maestro::ldap, 
    $admin = $maestro::maestro::admin,
    $admin_password = $maestro::maestro::admin_password,
    $master_password = $maestro::maestro::master_password,
    $mail_from = $maestro::maestro::mail_from,
    $basedir = $maestro::maestro::basedir,
    $homedir = $maestro::maestro::homedir) inherits maestro::params {
      
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

      # This requires something, but what? ->
      augeas { "update-default-configurations":
        changes => [
          "set default-configuration/users/*/password/#text[../../username/#text = 'admin'] ${admin_password}",
          "rm default-configuration/users/*[username/#text != 'admin']",
        ],
        incl => "${homedir}/conf/default-configurations.xml",
        lens => "Xml.lns",
        require => Class['maestro::maestro::package'],
      } ->
      file { "${basedir}/conf/default-configurations.xml":
        source  => "${homedir}/conf/default-configurations.xml",
        require => File["${basedir}/conf"],
      }
}
