class maestro::agent::package::rpm (
  $repo,
  $timestamp_version,
  $base_version)
{

  if $repo['url'] =~ /^(https:\/\/)(.*)$/ {
    $uri = "${2}"
  } 

  # When we have a proper yum repo, this variable can go away.
  $maestro_agent_source = "https://${uri}/com/maestrodev/lucee/agent/${base_version}/agent-${timestamp_version}-rpm.rpm"

  wget::authfetch { "fetch-agent-rpm":
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
  }

}
