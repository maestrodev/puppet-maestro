# Maestro default plugins
# define versions as parameters so they can be set from hiera
class maestro::plugins(
  $irc = '1.2',
  $continuum = '1.5',
  $scm = '1.0',
  $jenkins = '1.1.2',
  $jira = '1.0',
  $bamboo = '1.1',
  $fog = '1.3') {

  maestro::plugin { 'maestro-irc-plugin':
    version => $irc,
  }
  maestro::plugin { 'maestro-continuum-plugin':
    version => $continuum,
  }
  maestro::plugin { 'maestro-scm-plugin':
    version => $scm,
  }
  maestro::plugin { 'maestro-jenkins-plugin':
    version => $jenkins,
  }
  maestro::plugin { 'maestro-jira-plugin':
    version => $jira,
  }
  maestro::plugin { 'maestro-bamboo-plugin':
    version => $bamboo,
  }
  maestro::plugin { 'maestro-fog-plugin':
    version => $fog,
  }

}
