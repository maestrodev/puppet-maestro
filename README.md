puppet-maestro
==============

Puppet module for installing Maestro and related software

Simple configuration
--------------------

First, declare the variables that will be used across both nodes.

    $maestro_version = '4.11.0'
    $agent_version   = '1.6.0'
    
    # Choose the following passwords as you wish  
    # note that admin password needs to validate against the password rules (letters+numbers by default)
    $maestro_db_server_password = '...'   # Password on the Postgres admin user
    $maestro_db_password        = '...'   # Password on the Maestro database user
    $maestro_master_password    = '...'   # Password used to encrypt other passwords
    $maestro_adminpassword      = '...'   # Initial Maestro administrator user password
    
    # Use credentials provided by MaestroDev for trial / subscription
    $repo = {
      url      => 'https://repo.maestrodev.com/archiva/repository/all/',
      username => '...',
      password => '...',
    }


On the Maestro node, you'll need Maestro and ActiveMQ:

    class { java: distribution => 'java-1.6.0-openjdk' }

    include maestro

    class { 'maestro::maestro' :
      repo      => $repo,
      version   => $maestro_version,
    }

    # ActiveMQ, with Stomp connector enabled
    class { 'activemq': }
    class { 'activemq::stomp': }

On the agent node(s), install the agent.

    class { java: distribution => 'java-1.6.0-openjdk-devel' }

    class { 'maestro::agent':
      repo           => $repo,
      agent_version  => $agent_version,
    }


(The -devel alternate packaging is only needed if you are developing Java
software that will build on the agent. If not, you can use
java-1.6.0-openjdk).

You can then proceed to install other software as needed on the nodes - for
example Jenkins, Archiva or Sonar on the Maestro node (or standalone nodes if
required), and Maven, rake, and CI agents on the agent nodes.

For example, the following installs Archiva, sharing the user database with
Maestro:

    $jdbc_driver_url = "${repo['url']}/postgresql/postgresql/8.4-702.jdbc3/postgresql-8.4-702.jdbc3.jar"
    $archiva_jdbc = {
      url => "jdbc:postgresql://localhost/maestro",
      driver => "org.postgresql.Driver",
      username => "maestro",
      password => $maestro_db_password,
    }
    class { archiva:
      repo => $repo,
      version => "1.4-M1-maestro-3.4.3.1",
      port => 8082,
      archiva_jdbc => $archiva_jdbc,
      users_jdbc => $archiva_jdbc,
      jdbc_driver_url => $jdbc_driver_url,
      require => Postgres::Createdb[maestro],
    }


Other modules describe how to install that particular package.

Testing 
-------

bundle install
bundle exec rake spec


Development
-----------

vagrant up
vagrant provision (to apply changes as tweaking)


Installing plugins
------------------
Plugins can be installed from the Maestro Web UI or be automatically installed using the `maestro::plugin` definition in Puppet.

For example to install some common plugins, add this to the Maestro node.

    include maestro::plugins

