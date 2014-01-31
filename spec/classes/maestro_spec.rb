require 'spec_helper'

describe 'maestro::maestro' do

  let(:params) {{
      :version => '4.18.0',
      :db_server_password => 'myserverpassword',
      :db_password => 'mydbpassword',
      :admin_password => 'myadminpassword',
      :repo => {
          'id' => 'maestro-mirror',
          'username' => 'u',
          'password' => 'p',
          'url' => 'https://repo.maestrodev.com/archiva/repository/all'
      }
  }}

  shared_examples :default do
    it "should not enable fowarding in jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      should_not contain_file("/var/local/maestro/conf/jetty.xml").with_content =~ %r[<Set name="forwarded">true</Set>]
    end
    it { should contain_file("/usr/local/src") }

    it "should have default context paths", :compile do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = subject.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="contextPath">/lucee</Set>]
      content.should =~ %r[<Set name="contextPath">/</Set>]
    end

    it "should use database defaults and configured password" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = subject.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="url"><SystemProperty name="database.url" default="jdbc:postgresql://localhost/maestro"/></Set>]
      content.should =~ %r[<Set name="driverClassName"><SystemProperty name="database.driverClassName" default="org.postgresql.Driver"/></Set>]
      content.should =~ %r[<Set name="username"><SystemProperty name="database.username" default="maestro"/></Set>]
      content.should =~ %r[<Set name="password"><SystemProperty name="database.password" default="mydbpassword"/></Set>]
    end

    it "should create the right LuCEE configuration" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ /"agent_auto_activate": false,$/
      content.should =~ /"pass": "mydbpassword",$/
      content.should =~ /"username": "maestro",$/
      content.should =~ /"password": "maestro",$/
    end

    it "should create a maestro.properties file" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^google\.analytics\.propertyId = $/
    end

    it "should create the right LuCEE client configuration" do
      content = subject.resource('file', '/var/local/maestro/conf/lucee-lib.json').send(:parameters)[:content]
      content.should =~ /"username": "maestro",$/
      content.should =~ /"password": "maestro"$/
    end

    it "should adjust startup_wait.sh" do
      should contain_file("/tmp/startup_wait.sh")
      content = subject.resource('file', '/tmp/startup_wait.sh').send(:parameters)[:content]
      content.should =~ %r[psql -h localhost]
    end

    context "when creating a sysconfig file", :compile do
      let(:content) { subject.resource('file', '/etc/sysconfig/maestro').send(:parameters)[:content] }
      it { content.should =~ %r{^export HOME=/var/local/maestro$} }
      it { content.should =~ %r{^export MAESTRO_BASE=/var/local/maestro$} }
      it { content.should =~ /^RUN_AS_USER=maestro$/ }
      it { content.should =~ /^RUN_AS_USER=maestro$/ }
      it { content.should =~ %r{^WRAPPER_CMD=/usr/local/maestro/bin/wrapper$} }
    end
  end

  shared_examples :tarball do
    it_behaves_like :default
    it_behaves_like :wrapper
    it_behaves_like :pre_4_18
    it { should contain_exec("unpack-maestro") }
    it { should_not contain_package("maestro") }
    it { should contain_wget__authfetch("fetch-maestro") }
    it { should contain_exec("unpack-maestro").with_cwd("/usr/local") }
  end

  shared_examples :rpm do
    it_behaves_like :default
    it { should_not contain_exec("unpack-maestro") }
    it { should contain_package("maestro") }
    it { should contain_wget__authfetch("fetch-maestro-rpm") }
  end

  shared_examples :wrapper do
    it { should contain_file('/etc/init.d/maestro').with_content(%r{\. "/etc/sysconfig/\$APP_NAME"}) }
  end

  shared_examples :pre_4_18 do
    it { should contain_file('/var/local/maestro') }
    it { should contain_file('/var/local/maestro/conf/wrapper.conf').with_ensure('link') }
    it { should contain_file('/var/local/maestro/conf/webdefault.xml').with_ensure('link') }
    it { should contain_file('/var/local/maestro/conf/default-configurations.xml').with_ensure('link') }
  end


  context "when using rpm package", :compile do
    let(:params) { super().merge({
      :package_type => 'rpm'
    }) }

    it_behaves_like :rpm
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
    it { should_not contain_file('/var/local/maestro') }
    it { should_not contain_file('/var/local/maestro/conf') }
    it { should_not contain_file('/var/local/maestro/conf/webdefault.xml') }
  end

  context "when using tarball package", :compile do
    let(:params) { super().merge({
      :package_type => 'tarball'
    }) }

    it_behaves_like :tarball
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
  end

  context "when installing on Maestro up to 4.11.0", :compile do
    let(:params) { super().merge({
      :version => "4.11.0",
    }) }

    it_behaves_like :tarball
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("link") }
    it { should contain_package('libxml2-devel').with_ensure('present') }
    it { should contain_package('libxslt-devel').with_ensure('present') }
  end

  context "when installing Maestro 4.12.0+", :compile do
    let(:params) { super().merge({
      :version => "4.12.0",
    }) }

    it_behaves_like :tarball
    it { should_not contain_package('libxml2-devel') }
    it { should_not contain_package('libxslt-devel') }
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("link") }
  end

  context "when installing Maestro 4.13.0+", :compile do
    let(:params) { super().merge({
      :version => "4.13.0",
    }) }

    it_behaves_like :tarball
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
  end

  context "when installing Maestro 4.13.0+ SNAP", :compile do
    let(:params) { super().merge({
      :version => "4.13.0-SNAPSHOT",
    }) }

    it_behaves_like :tarball
    it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
  end

  context "when installing Maestro <4.18.0", :compile do
    let(:params) { super().merge({ :version => "4.17.3" }) }

    context "with rpm", :compile do
      let(:params) { super().merge({ :package_type => "rpm" }) }
      it_behaves_like :pre_4_18
      it_behaves_like :rpm
      it_behaves_like :wrapper
      it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
    end

    context "with tarball", :compile do
      let(:params) { super().merge({ :package_type => "tarball" }) }
      it_behaves_like :tarball
      it { should contain_file('/var/maestro/lucee-lib.json').with_ensure("absent") }
    end
  end


  context "google analytics configuration", :compile do
    let(:params) { super().merge({
         :ga_property_id => "ABC123",
     }) }

    it "should create a maestro.properties file" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^google\.analytics\.propertyId = ABC123$/
    end
  end

  context "when using default web properties configuration", :compile do
    it "should create a maestro.properties file" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should_not =~ /^feature\.dashboard\.enabled = true$/
    end
  end

  context "when using web properties configuration", :compile do
    let(:params) { super().merge({
      :web_config_properties => {
        "feature.dashboard.enabled" => "true"
      }
    }) }

    it "should create a maestro.properties file" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^feature\.dashboard\.enabled = true$/
    end
  end

  context "when using custom lucee password", :compile do
    let(:params) { super().merge({
        :lucee_username => "lucee",
        :lucee_password => "my-lucee-passwd",
    }) }

    it "should create the right LuCEE configuration" do
      content = subject.resource('file', '/var/local/maestro/conf/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ /"username": "lucee",$/
      content.should =~ /"password": "my-lucee-passwd",$/
    end

    it "should create the right LuCEE client configuration" do
      content = subject.resource('file', '/var/local/maestro/conf/lucee-lib.json').send(:parameters)[:content]
      content.should =~ /"username": "lucee",$/
      content.should =~ /"password": "my-lucee-passwd"$/
    end
  end

  context "when using a custom home directory", :compile do
    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:facts) {{ :hostname => 'test-host-name' }}

    it { should contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }
    it { should contain_file('/etc/sysconfig/maestro').with_content(%r[export HOME=/var/local/u]) }
  end

  context "when using a custom home directory without lucee", :compile do

    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:params) { super().merge({
        :lucee => false
    }) }

    it { should_not contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }
    it { should contain_file('/etc/sysconfig/maestro').with_content(%r[export HOME=/var/local/u]) }
  end

  context "when using a reverse proxy", :compile do
    let(:params) { super().merge({
      :jetty_forwarded => true
    }) }
    it "should enable fowarding in jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml").with_content =~ %r[<Set name="forwarded">true</Set>]
    end
  end

  context "when context paths are customised", :compile do
    let(:params) { super().merge({
        :maestro_context_path => "/foo",
        :lucee_context_path => "/bar",
    })}
    it "should have default context paths", :compile do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = subject.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="contextPath">/foo</Set>]
      content.should =~ %r[<Set name="contextPath">/bar</Set>]
      content.should_not =~ %r[<Set name="contextPath">/</Set>]
      content.should_not =~ %r[<Set name="contextPath">/lucee</Set>]
    end
  end

  context "when not using LDAP for security", :compile do
    # as some defaults are interpolated with spring, they must be set
    # regardless of being used
    it "should still populate the required default properties" do
      security_file = "/var/local/maestro/conf/security.properties"
      should contain_file(security_file)
      content = subject.resource('file', security_file).send(:parameters)[:content]
      content.should include("ldap.config.group.role.attribute=cn")
      content.should include("ldap.config.group.search.base.dn=ou=groups")
      content.should include("ldap.config.group.search.filter=(uniqueMember={0})")
      content.should include("ldap.config.group.search.subtree=false")
    end
  end

  context "when using a different JDBC URL", :compile do
    let(:params) { super().merge({
      :jdbc_users => {
        'url' => "jdbc:postgresql://anotherhost/users",
        'driver' => "org.postgresql.Driver",
        'username' => "maestro",
      }
    })}
    it "should populate jetty.xml" do
      should contain_file("/var/local/maestro/conf/jetty.xml")
      content = subject.resource('file', '/var/local/maestro/conf/jetty.xml').send(:parameters)[:content]
      content.should =~ %r[<Set name="url"><SystemProperty name="database.url" default="jdbc:postgresql://anotherhost/users"/></Set>]
      content.should =~ %r[<Set name="driverClassName"><SystemProperty name="database.driverClassName" default="org.postgresql.Driver"/></Set>]
      content.should =~ %r[<Set name="username"><SystemProperty name="database.username" default="maestro"/></Set>]
      content.should =~ %r[<Set name="password"><SystemProperty name="database.password" default="mydbpassword"/></Set>]
    end
    it "should adjust startup_wait.sh" do
      should contain_file("/tmp/startup_wait.sh")
      content = subject.resource('file', '/tmp/startup_wait.sh').send(:parameters)[:content]
      content.should =~ %r[psql -h anotherhost]
    end
  end
end

