class maestro::agent::package::rpm (
    $repo,
    $timestamp_version,
    $base_version)
{

    if $repo['url'] =~ /^(https:\/\/)(.*)$/ {
      $uri = "${2}"
    } 

    # When we have a proper yum repo, this variable can go away.
     $maestro_agent_source = "https://${repo['username']}:${repo['password']}@${uri}/com/maestrodev/lucee/agent/${base_version}/agent-${timestamp_version}-rpm.rpm"

    package { 'maestro-agent':
     ensure => latest,
     source => $maestro_agent_source,
     provider => rpm,
    }

}