# Maestro default plugins
# define versions as parameters so they can be set from hiera
class maestro::plugins(
  $irc = '1.2',
  $continuum = '1.5',
  $scm = '1.0',
  $jenkins = '1.1.2',
  $jira = '1.0',
  $bamboo = '1.1',
  $fog = '1.3',
  $rpm = '1.0',
  $puppet = '1.0',
  $gemfury = '1.0',
  $rightscale = '1.0',
  $flowdock = '1.0',
  $cucumber = '1.0'
  ) {

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
  maestro::plugin { 'maestro-rpm-plugin':
    version => $rpm,
  }
  maestro::plugin { 'maestro-puppet-plugin':
    version => $puppet,
  }
  maestro::plugin { 'maestro-gemfury-plugin':
    version => $gemfury,
  }
  maestro::plugin { 'maestro-rightscale-plugin':
    version => $rightscale,
  }
  maestro::plugin { 'maestro-flowdock-plugin':
    version => $flowdock,
  }
  maestro::plugin { 'maestro-cucumber-plugin':
    version => $cucumber,
  }

}
