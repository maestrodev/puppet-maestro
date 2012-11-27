class maestro::agent::package::tarball(
  $repo,
  $base_version,
  $timestamp_version,
  $srcdir,
  $basedir,
  $agent_user,
  $agent_group,
  $agent_user_home) {

    wget::authfetch { 'fetch-agent':
      user        => $repo['username'],
      password    => $repo['password'],
      source      => "${repo['url']}/com/maestrodev/lucee/agent/${base_version}/agent-${timestamp_version}-bin.tar.gz",
      destination => "${srcdir}/agent-${timestamp_version}-bin.tar.gz",
      require     => File[$srcdir],
    } ->
    exec {"rm -rf ${basedir}":
      unless => "egrep \"^${timestamp_version}$\" ${srcdir}/maestro-agent.version",
    } ->
    exec { 'unpack-agent':
      command => "tar zxf ${srcdir}/agent-${timestamp_version}-bin.tar.gz && chown -R ${agent_user}:${agent_group} maestro-agent ${agent_user_home}",
      creates => "${basedir}/lib",
      cwd     => '/usr/local', # TODO use $basedir instead of hardcoded
      path    => '/bin/:/usr/bin:/usr/sbin',
      notify  => Service['maestro-agent'],
    }

}
