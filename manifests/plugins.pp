# Maestro default plugins
class maestro::plugins() {

  maestro::plugin { 'maestro-irc-plugin':
    version => '1.2',
  }
  maestro::plugin { 'maestro-continuum-plugin':
    version => '1.5',
  }
  maestro::plugin { 'maestro-scm-plugin':
    version => '1.0',
  }
  maestro::plugin { 'maestro-jenkins-plugin':
    version => '1.1.2',
  }
  maestro::plugin { 'maestro-jira-plugin':
    version => '1.0',
  }
  maestro::plugin { 'maestro-bamboo-plugin':
    version => '1.1',
  }
  maestro::plugin { 'maestro-fog-plugin':
    version => '1.3',
  }

}
