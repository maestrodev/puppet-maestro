define maestro::plugin($version) {
  $user_home = $maestro::params::user_home

  Exec { path => '/bin:/usr/bin' }

  # If the version is a Maven snapshot, transform the base version to it's
  # SNAPSHOT indicator
  if $version =~ /^(.*)-[0-9]{8}\.[0-9]{6}-[0-9]+$/ {
    $base_version = "${1}-SNAPSHOT"
  } else {
    $base_version = $version
  }

  $plugin_folder = "${user_home}/.maestro/plugins"
  $plugin_file = "${name}-${version}-bin.zip"

  # download the plugin to /usr/local/src
  wget::authfetch { "fetch-maestro-plugin-${name}":
    user        => $maestro::repo['username'],
    password    => $maestro::repo['password'],
    source      => "${maestro::repo['url']}/com/maestrodev/${name}/${base_version}/${name}-${version}-bin.zip",
    destination => "/usr/local/src/${name}-${version}-bin.zip",
    require     => [File['/usr/local/src'], File["${user_home}/.maestro/plugins"]],
  } ->

  # copy to .maestro/plugins if it hasn't been installed already
  exec { "cp /usr/local/src/${name}-${version}-bin.zip ${plugin_folder}/${plugin_file}":
    unless => "test -s ${plugin_folder}/installed/${plugin_file}",
  } ->

  # verify that plugin has been installed correctly in Maestro
  exec { "wait-plugin-installed-${name}":
    command   => "test -s ${plugin_folder}/installed/${plugin_file} || test -s ${plugin_folder}/failed/${plugin_file}",
    unless    => "test -s ${plugin_folder}/installed/${plugin_file} || test -s ${plugin_folder}/failed/${plugin_file}",
    tries     => 30,
    try_sleep => 4,
    require   => [Exec['startup_wait']],
  } ->
  exec { "assert-plugin-installed-${name}":
    command   => "test -s ${plugin_folder}/installed/${plugin_file}",
    unless    => "test -s ${plugin_folder}/installed/${plugin_file}",
  }

}
