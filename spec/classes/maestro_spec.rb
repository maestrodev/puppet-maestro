require 'spec_helper'

describe 'maestro::maestro' do
  include_context :centos

  DEFAULT_PARAMS = {
      :version => '4.0',
      :db_server_password => 'myserverpassword',
      :db_password => 'mydbpassword',
      :admin_password => 'myadminpassword',
      :repo => {
          'id' => 'maestro-mirror',
          'username' => 'u',
          'password' => 'p',
          'url' => 'https://repo.maestrodev.com/archiva/repository/all'
      }
  }

  let(:params) { DEFAULT_PARAMS }

  context "when using defaults" do
    it { should contain_file '/var/local/maestro' }
    it "should not enable fowarding in jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      should_not contain_file("/var/local/maestro/conf/jetty.xml").with_content =~ %r[<Set name="forwarded">true</Set>]
    end
    it { should contain_exec("unpack-maestro") }
    it { should contain_file("/usr/local/src") }

    it "should have default context paths" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = catalogue.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="contextPath">/lucee</Set>]
      content.should =~ %r[<Set name="contextPath">/</Set>]
    end

    it "should use database defaults and configured password" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = catalogue.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="url"><SystemProperty name="database.url" default="jdbc:postgresql://localhost/maestro"/></Set>]
      content.should =~ %r[<Set name="driverClassName"><SystemProperty name="database.driverClassName" default="org.postgresql.Driver"/></Set>]
      content.should =~ %r[<Set name="username"><SystemProperty name="database.username" default="maestro"/></Set>]
      content.should =~ %r[<Set name="password"><SystemProperty name="database.password" default="mydbpassword"/></Set>]
    end

    it "should create the right LuCEE configuration" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ /"agent_auto_activate": false,$/
      content.should =~ /"pass": "mydbpassword",$/
      content.should =~ /"username": "maestro",$/
      content.should =~ /"password": "maestro",$/
    end

    it "should create a maestro.properties file" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^google\.analytics\.propertyId = $/
    end

    it "should create a wrapper script" do
      content = catalogue.resource('file', '/etc/init.d/maestro').send(:parameters)[:content]
      content.should =~ /^export HOME=\/var\/local\/maestro$/
      content.should =~ /^export MAESTRO_BASE=\/var\/local\/maestro$/
      content.should =~ /^RUN_AS_USER=maestro$/
    end

    it "should create the right LuCEE client configuration" do
      content = catalogue.resource('file', '/var/local/maestro/conf/lucee-lib.json').send(:parameters)[:content]
      content.should =~ /"username": "maestro",$/
      content.should =~ /"password": "maestro"$/
    end
  end

  context "google analytics configuration" do
    let(:params) { DEFAULT_PARAMS.merge({
         :ga_property_id => "ABC123",
     }) }

    it "should create a maestro.properties file" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^google\.analytics\.propertyId = ABC123$/
    end
  end

  context "when using default web properties configuration" do
    it "should create a maestro.properties file" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should_not =~ /^feature\.dashboard\.enabled = true$/
    end
  end

  context "when using web properties configuration" do
    let(:params) { DEFAULT_PARAMS.merge({
      :web_config_properties => {
        "feature.dashboard.enabled" => "true"
      }
    }) }

    it "should create a maestro.properties file" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^feature\.dashboard\.enabled = true$/
    end
  end

  context "when using custom lucee password" do
    let(:params) { DEFAULT_PARAMS.merge({
        :lucee_username => "lucee",
        :lucee_password => "my-lucee-passwd",
    }) }

    it "should create the right LuCEE configuration" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ /"username": "lucee",$/
      content.should =~ /"password": "my-lucee-passwd",$/
    end

    it "should create the right LuCEE client configuration" do
      content = catalogue.resource('file', '/var/local/maestro/conf/lucee-lib.json').send(:parameters)[:content]
      content.should =~ /"username": "lucee",$/
      content.should =~ /"password": "my-lucee-passwd"$/
    end
  end

  context "when using a custom home directory" do
    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:facts) { super().merge({:hostname => 'test-host-name'}) }

    it { should contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }

    it { should contain_file("/etc/init.d/maestro")}
    it "should set the HOME variable correctly in the startup script" do
      should contain_file('/etc/init.d/maestro').with_content =~ %r[export HOME=/var/local/u]
    end
  end

  context "when using a custom home directory without lucee" do

    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:params) { DEFAULT_PARAMS.merge({
        :lucee => false
    }) }

    it { should_not contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }

    it { should contain_file("/etc/init.d/maestro")}
    it "should set the HOME variable correctly in the startup script" do
      content = catalogue.resource('file', '/etc/init.d/maestro').send(:parameters)[:content]
      content.should =~ %r[export HOME=/var/local/u]
    end
  end

  context "when using a reverse proxy" do
    let(:params) { DEFAULT_PARAMS.merge({
      :jetty_forwarded => true
    }) }
    it "should enable fowarding in jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml").with_content =~ %r[<Set name="forwarded">true</Set>]
    end
  end

  context "when using rpm package" do
    let(:params) { DEFAULT_PARAMS.merge({
      :package_type => 'rpm'
    }) }
    it { should contain_package("maestro") }
  end

  context "when using tarball package" do
    let(:params) { DEFAULT_PARAMS.merge({
      :package_type => 'tarball'
    }) }
    it { should_not contain_package("maestro") }
    it { should contain_wget__authfetch("fetch-maestro") }
    it { should contain_exec("unpack-maestro").with_cwd("/usr/local") }
  end

  context "when installing on Maestro up to 4.11.0" do
    let(:params) { DEFAULT_PARAMS.merge({
      :version => "4.11.0",
    }) }

    it { should contain_package('libxml2-devel').with_ensure('installed') }
    it { should contain_package('libxslt-devel').with_ensure('installed') }
  end

  context "when installing Maestro 4.12.0+" do
    let(:params) { DEFAULT_PARAMS.merge({
      :version => "4.12.0",
    }) }

    it { should_not contain_package('libxml2-devel') }
    it { should_not contain_package('libxslt-devel') }
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("link") }
  end

  context "when installing Maestro 4.13.0+" do
    let(:params) { DEFAULT_PARAMS.merge({
      :version => "4.13.0",
    }) }

    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
  end

  context "when installing Maestro 4.13.0+ SNAP" do
    let(:params) { DEFAULT_PARAMS.merge({
      :version => "4.13.0-SNAPSHOT",
    }) }

    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
  end

  context "when context paths are customised" do
    let(:params) { DEFAULT_PARAMS.merge({
        :maestro_context_path => "/foo",
        :lucee_context_path => "/bar",
    })}
    it "should have default context paths" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = catalogue.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="contextPath">/foo</Set>]
      content.should =~ %r[<Set name="contextPath">/bar</Set>]
      content.should_not =~ %r[<Set name="contextPath">/</Set>]
      content.should_not =~ %r[<Set name="contextPath">/lucee</Set>]
    end
  end

  context "when not using LDAP for security" do
    # as some defaults are interpolated with spring, they must be set
    # regardless of being used
    it "should still populate the required default properties" do
      security_file = "/var/local/maestro/conf/security.properties"
      should contain_file(security_file)
      content = catalogue.resource('file', security_file).send(:parameters)[:content]
      content.should include("ldap.config.group.role.attribute=cn")
      content.should include("ldap.config.group.search.base.dn=ou=groups")
      content.should include("ldap.config.group.search.filter=(uniqueMember={0})")
      content.should include("ldap.config.group.search.subtree=false")
    end
  end

  context "when using a different JDBC URL" do
    let(:params) { DEFAULT_PARAMS.merge({
      :jdbc_users => {
        'url' => "jdbc:postgresql://localhost/users",
        'driver' => "org.postgresql.Driver",
        'username' => "maestro",
      }
    })}
    it "should populate jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = catalogue.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="url"><SystemProperty name="database.url" default="jdbc:postgresql://localhost/users"/></Set>]
      content.should =~ %r[<Set name="driverClassName"><SystemProperty name="database.driverClassName" default="org.postgresql.Driver"/></Set>]
      content.should =~ %r[<Set name="username"><SystemProperty name="database.username" default="maestro"/></Set>]
      content.should =~ %r[<Set name="password"><SystemProperty name="database.password" default="mydbpassword"/></Set>]
    end
  end
end

