class maestro::agent::package::rpm (
  $repo,
  $timestamp_version,
  $base_version)
{
  # When we have a proper yum repo, this variable can go away.
  $maestro_agent_source = "${repo['url']}/com/maestrodev/lucee/agent/${base_version}/agent-${timestamp_version}-rpm.rpm"

  notice("This will ALWAYS FAIL in --noop mode, since the wget doesn't leave a real file to be parsed in /usr/local/src, so ignore it")
  wget::authfetch { 'fetch-agent-rpm':
    user        => $repo['username'],
    password    => $repo['password'],
    source      => $maestro_agent_source,
    destination => "/usr/local/src/agent-${timestamp_version}.rpm",
    require     => File['/usr/local/src'],
  } ->
  package { 'maestro-agent':
    ensure   => latest,
    source   => "/usr/local/src/agent-${timestamp_version}.rpm",
    provider => rpm,
    before   => [File[$maestro::agent::agent_user_home]], # so agent owner is set by puppet afterwards
  }

}
