# Maestro default plugins
# define versions as parameters so they can be set from hiera
class maestro::plugins(
  $bamboo = '1.1',
  $continuum = '1.6',
  $cucumber = '1.0',
  $flowdock = '1.0',
  $fog = '1.5',
  $gemfury = '1.0',
  $irc = '1.2',
  $jenkins = '1.4.3',
  $jira = '1.0',
  $puppet = '1.0',
  $rightscale = '1.0',
  $rpm = '1.0',
  $scm = '1.0'
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
