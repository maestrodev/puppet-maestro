puppet-maestro
==============

Puppet module for installing Maestro and related software

Simple configuration
--------------------

First, declare the variables that will be used across both nodes.

```
  $maestro_version = '4.3.2'
  $agent_version   = '0.1.6'
  
  # Choose the following passwords as you wish  
  # note that admin password needs to validate against the password rules (letters+numbers by default)
  $maestro_db_server_password = '...'   # Password on the Postgres admin user
  $maestro_db_password        = '...'   # Password on the Maestro database user
  $maestro_master_password    = '...'   # Password used to encrypt other passwords
  $maestro_admin_password     = '...'   # Initial Maestro administrator user password
  
  # Use credentials provided by MaestroDev for trial / subscription
  $repo = {
    url      => 'https://repo.maestrodev.com/archiva/repository/all/',
    username => '...',
    password => '...',
  }
```

On the Maestro node, you'll need Maestro and ActiveMQ:

```
  class { java: distribution => 'java-1.6.0-openjdk' }

  include maestro

  class { 'maestro::maestro' :
    repo      => $repo,
    version   => $maestro_version,
  }

  # ActiveMQ, with Stomp connector enabled
  include activemq

  augeas { 'configure-activemq':
    changes => [
      'rm beans/import',
      'set beans/broker/transportConnectors/transportConnector/#attribute/name stomp+nio',
      'set beans/broker/transportConnectors/transportConnector/#attribute/uri stomp+nio://0.0.0.0:61613?transport.closeAsync=false',
    ],
    incl    => '/opt/activemq/conf/activemq.xml',
    lens    => 'Xml.lns',
    require => File['/opt/activemq'],
    notify  => Service['activemq'],
  }
```

On the agent node(s), install the agent.

```
  class { java: distribution => 'java-1.6.0-openjdk-devel' }

  class { 'maestro::agent':
    repo           => $repo,
    agent_version  => $agent_version,
  }
```

(The -devel alternate packaging is only needed if you are developing Java
software that will build on the agent. If not, you can use
java-1.6.0-openjdk).

You can then proceed to install other software as needed on the nodes - for
example Jenkins, Archiva and Sonar on the Maestro node (or standalone nodes
if required), and Maven, rake, and CI agents on the agent nodes.
