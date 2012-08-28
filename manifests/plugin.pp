define maestro::plugin($version) {
  $user_home = $maestro::params::user_home

  

  Exec { path => "/bin:/usr/bin" }

  # If the version is a Maven snapshot, transform the base version to it's
  # SNAPSHOT indicator
  if $version =~ /^(.*)-[0-9]{8}\.[0-9]{6}-[0-9]+$/ {
    $base_version = "${1}-SNAPSHOT"
  } else {
    $base_version = $version
  }

  # download the plugin to /usr/local/src
  if ! defined(File['/usr/local/src']) {
    file {'/usr/local/src':
      ensure => directory,
      before => Wget::Authfetch["fetch-maestro-plugin-${name}"],
    }
  }
  wget::authfetch { "fetch-maestro-plugin-${name}":
    user => $maestro::repo['username'],
    password => $maestro::repo['password'],
    source => "${maestro::repo['url']}/com/maestrodev/${name}/${base_version}/${name}-${version}-bin.zip",
    destination => "/usr/local/src/${name}-${version}-bin.zip",
    require => File["${user_home}/.maestro/plugins"],
  } ->

  # copy to .maestro/plugins if it hasn't been installed already
  exec { "cp /usr/local/src/${name}-${version}-bin.zip ${user_home}/.maestro/plugins/${name}-${version}-bin.zip":
    unless => "test -s ${user_home}/.maestro/plugins/installed/${name}-${version}-bin.zip",
  }
}
