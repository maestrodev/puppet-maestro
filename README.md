puppet-maestro
==============

Puppet module for installing Maestro and related software

Simple configuration
--------------------

First, declare the variables that will be used across both nodes.

```
  $maestro_version = "4.3.2"
  $maestro_db_password = "..."
  $repo = {
    url => "https://repo.maestrodev.com/archiva/repository/all/",
    username => "...",
    password => "...",
  }
```

On the Maestro node, you'll need Maestro and ActiveMQ:

```
  include maestro

  class { 'maestro::maestro' :
    repo => $repo,
    db_server_password => $maestro_db_password,
    basedir => "/var/local/maestro",
    mail_from => $mail_from,
    version => $maestro_version,
    maxmemory => 512,
  }

  # ActiveMQ
  class { "activemq":
    version => "5.5.0",
    max_memory => "256"
  }

  augeas { "configure-activemq":
    changes => [
      "rm beans/import",
      "set beans/broker/transportConnectors/transportConnector/#attribute/name
stomp+nio",
      "set beans/broker/transportConnectors/transportConnector/#attribute/uri
stomp+nio://0.0.0.0:61613?transport.closeAsync=false",
    ],
    incl => "/opt/activemq/conf/activemq.xml",
    lens => "Xml.lns",
    require => File["/opt/activemq"],
    notify  => Service["activemq"],
  }
```

On the agent node(s), install the agent.

```
  class { 'maestro::agent':
    agent_version  => "0.1.6",
    repo           => $repo,
  }
```

You can then proceed to install other software as needed on the nodes - for
example Jenkins, Archiva and Sonar on the Maestro node (or standalone nodes
if required), and Maven, rake, and CI agents on the agent nodes.
