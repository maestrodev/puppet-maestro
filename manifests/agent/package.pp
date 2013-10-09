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

  # in RPM agents >= 2.1.0 this is only needed to ensure the owner and group
  file { '/var/local':
    ensure  => directory,
  } ->
  file { [$agent_user_home,"${agent_user_home}/logs","${agent_user_home}/conf","${agent_user_home}/tmp"]:
    ensure  => directory,
    owner   => $agent_user,
    group   => $agent_group,
  }

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

      class { 'maestro::agent::package::rpm':
        repo              => $repo,
        timestamp_version => $timestamp_version,
        base_version      => $base_version,
      }

      # older agents
      if versioncmp($version, '2.1.0') < 0 {

        file { $basedir:
          ensure  => directory,
          owner   => $agent_user,
          group   => $agent_group,
        }

        file { "${basedir}/logs":
          ensure  => link,
          target  => "${agent_user_home}/logs",
          owner   => $agent_user,
          group   => $agent_group,
          force   => true,
        } ->
        # until maestro-agent properly sets the working directory / temp
        # directory
        file { "${basedir}/bin":
          ensure       => directory,
          owner        => $agent_user,
          group        => $agent_group,
          mode         => '0755',
          recurse      => true, # sets all the scripts to be executable
          recurselimit => 1,
        } ->
        file { "${basedir}/bin/tmp":
          ensure => directory,
          owner  => $agent_user,
          group  => $agent_group,
        }

      }

    }
    default: {
      fail("Invalid Maestro package type: ${type}")
    }
  }

}
