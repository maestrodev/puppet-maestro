class maestro::package::rpm(
  $repo,
  $version,
  $base_version
  )
{

  if $repo['url'] =~ /^(https:\/\/)(.*)$/ {
    $uri = "${2}"
  } 
  
  # When we have a proper yum repo, this variable can go away.
   $maestro_source = "https://${repo['username']}:${repo['password']}@${uri}/com/maestrodev/maestro/rpm/maestro/${base_version}/maestro-${version}.rpm"
  
  package { 'maestro':
   ensure => latest,
   source => $maestro_source,
   provider => rpm,
  }
}