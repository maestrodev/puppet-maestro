class maestro::maestro::package::rpm(
  $repo,
  $version,
  $base_version)
{

  if $repo['url'] =~ /^(https:\/\/)(.*)$/ {
    $uri = "${2}"
  } 
  
  # When we have a proper yum repo, this variable can go away.
  $maestro_source = "https://${uri}/com/maestrodev/maestro/rpm/maestro/${base_version}/maestro-${version}.rpm"
  
  wget::authfetch { "fetch-maestro-rpm":
    user        => $repo['username'],
    password    => $repo['password'],
    source      => $maestro_source,
    destination => "/usr/local/src/maestro-${version}.rpm",
    require     => File['/usr/local/src'],
  } ->
  package { 'maestro':
    ensure   => latest,
    source   => "/usr/local/src/maestro-${version}.rpm",
    provider => rpm,
  }
  
}