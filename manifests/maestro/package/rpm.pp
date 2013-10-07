class maestro::maestro::package::rpm(
  $repo,
  $version,
  $base_version)
{
  # When we have a proper yum repo, this variable can go away.
  $maestro_source = "${repo['url']}/com/maestrodev/maestro/rpm/maestro/${base_version}/maestro-${version}.rpm"

  ensure_resource('file', '/usr/local/src', {'ensure' => 'directory' })

  wget::authfetch { 'fetch-maestro-rpm':
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
    before   => File['/etc/sysconfig/maestro'],
  }

}
