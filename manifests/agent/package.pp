class maestro::agent::package(
  $type = $maestro::agent::package_type,
  $repo = $maestro::agent::repo,
  $version = $maestro::agent::agent_version,
  $srcdir = $maestro::agent::srcdir,
  $basedir = $maestro::agent::basedir,
  $agent_user = $maestro::agent::agent_user,
  $agent_group = $maestro::agent::agent_group,
  $agent_user_home = $maestro::agent::agent_user_home) {


  $timestamp_version = $version # version is a release
  $base_version = snapshotbaseversion($version)

  ensure_resource('file', $srcdir, {'ensure' => 'directory' })

  case $type {

    'tarball': {
      anchor { 'maestro::agent::package::begin': } -> Class['maestro::agent::package::tarball'] -> anchor { 'maestro::agent::package::end': }

      class { 'maestro::agent::package::tarball':
        repo              => $repo,
        timestamp_version => $timestamp_version,
        base_version      => $base_version,
        srcdir            => $srcdir,
        basedir           => $basedir,
        agent_user        => $agent_user,
        agent_group       => $agent_group,
        agent_user_home   => $agent_user_home,
      }
    }
    'rpm': {
      anchor { 'maestro::agent::package::begin': } -> Class['maestro::agent::package::rpm'] -> anchor { 'maestro::agent::package::end': }

      if $version < '2.1.0' {
        fail("Agent version set to ${version} but Maestro module requires Agent > 2.1.x")
      }

      class { 'maestro::agent::package::rpm':
        repo              => $repo,
        timestamp_version => $timestamp_version,
        base_version      => $base_version,
      }
    }
    default: {
      fail("Invalid Maestro package type: ${type}")
    }
  }

}
