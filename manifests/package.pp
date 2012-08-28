class maestro::package(
  $type = 'tarball',
  $repo,
  $version,
  $base_version,
  $srcdir,
  $homedir,
  $basedir) {
  
  case $type {
    'tarball': {
      anchor { 'maestro::package::begin': } -> Class['maestro::package::tarball'] -> anchor { 'maestro::package::end': }

      class { 'maestro::package::tarball':
        repo => $repo,
        version => $version,
        base_version => $base_version,
        srcdir => $srcdir,
        homedir => $homedir,
        basedir => $basedir,
      }
    }
    'rpm': {
       anchor { 'maestro::package::begin': } -> Class['maestro::package::rpm'] -> anchor { 'maestro::package::end': }
       class { 'maestro::package::rpm':
          repo => $repo,
          version => $version,
          base_version => $base_version,
        }
    }
    default: {
      fail("Invalid Maestro package type: ${type}")
    }    
  }
  
}