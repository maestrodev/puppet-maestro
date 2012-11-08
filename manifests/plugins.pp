# Maestro default plugins
class maestro::plugins() {

  maestro::plugin { 'maestro-irc-plugin':
    version => '1.2',
  }
  maestro::plugin { 'maestro-continuum-plugin':
    version => '1.5-20121031.080048-5',
  }
  maestro::plugin { 'maestro-scm-plugin':
    version => '1.0-20120710.051326-11',
  }
  maestro::plugin { 'maestro-jenkins-plugin':
    version => '1.1-20121025.194334-2',
  }
  maestro::plugin { 'maestro-bamboo-plugin':
    version => '1.0-20121025.131245-1',
  }
  maestro::plugin { 'maestro-fog-plugin':
    version => '1.1-20121004.151511-1',
  }

}
