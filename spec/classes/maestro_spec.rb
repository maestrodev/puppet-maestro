require 'spec_helper'

describe 'maestro::maestro' do
  let(:facts) { {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat',
      :postgres_default_version => '8.4',
  } }

  DEFAULT_PARAMS = {
      :version => '1.0',
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
    
    it "should create the right LuCEE configuration" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ /"agent_auto_activate": false,$/
      content.should =~ /"pass": "mydbpassword",$/
      content.should =~ /"username": "maestro",$/
      content.should =~ /"password": "maestro",$/
    end

    it "should create a maestro.properties file" do
      content = catalogue.resource('file', '/var/local/maestro/conf/maestro.properties').send(:parameters)[:content]
      content.should =~ /^google\.analytics\.propertyId = $/
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

  context "when using custom lucee password" do
    let(:params) { DEFAULT_PARAMS.merge({
        :lucee_username => "lucee",
        :lucee_password => "my-lucee-passwd",
    }) }

    it "should create the right LuCEE configuration" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
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
    let(:facts) { {
        :hostname => 'test-host-name',
        :operatingsystem => 'CentOS',
        :kernel => 'Linux',
        :osfamily => 'RedHat',
        :postgres_default_version => '8.4',} }

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
end

