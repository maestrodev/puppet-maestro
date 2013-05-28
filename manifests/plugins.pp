# Maestro default plugins
# define plugins and versions as parameters so they can be set from hiera
# defaults here for backwards compatibility - expect this will likely be
# supplied in most Puppet sites to ease updating
class maestro::plugins(
  $plugins = {
    'maestro-bamboo-plugin' => { version => '1.1' },
    'maestro-continuum-plugin' => { version => '1.6' },
    'maestro-cucumber-plugin' => { version => '1.0' },
    'maestro-flowdock-plugin' => { version => '1.0' },
    'maestro-fog-plugin' => { version => '1.5' },
    'maestro-gemfury-plugin' => { version => '1.0' },
    'maestro-irc-plugin' => { version => '1.2' },
    'maestro-jenkins-plugin' => { version => '1.4.4' },
    'maestro-jira-plugin' => { version => '1.0' },
    'maestro-puppet-plugin' => { version => '1.0' },
    'maestro-rightscale-plugin' => { version => '1.0' },
    'maestro-rpm-plugin' => { version => '1.0' },
    'maestro-scm-plugin' => { version => '1.0' },
    'maestro-ssh-plugin' => { version => '1.0' },
  } ) {
  create_resources('maestro::plugin', $plugins)
}
