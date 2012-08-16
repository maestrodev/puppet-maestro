require 'spec_helper'

describe 'maestro::maestro' do

  DEFAULT_PARAMS = {
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
    it "should not enable fowarding in jetty.xml" do                                  
      content = catalogue.resource("file", "/var/local/maestro/conf/jetty.xml").send(:parameters)[:content]
      content.should_not =~ %r[<Set name="forwarded">true</Set>]                      
    end 
  end

  context "when using a custom home directory" do
    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:facts) { {:hostname => 'test-host-name'} }

    it { should contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }

    it { should contain_file("/etc/init.d/maestro")}
    it "should set the HOME variable correctly in the startup script" do
      content = catalogue.resource('file', '/etc/init.d/maestro').send(:parameters)[:content]
      content.should =~ %r[export HOME=/var/local/u]
    end
  end

  context "when using a custom home directory without lucee" do
    let(:pre_condition) { %Q[
      class { 'maestro::params': user_home => '/var/local/u' } 
    ]}
    let(:params) { {
        :lucee => false
    }.merge(DEFAULT_PARAMS) }

    it { should_not contain_file('/var/local/u/.maestro/plugins') }
    it { should_not contain_file('/home/maestro/.maestro/plugins') }

    it { should contain_file("/etc/init.d/maestro")}
    it "should set the HOME variable correctly in the startup script" do
      content = catalogue.resource('file', '/etc/init.d/maestro').send(:parameters)[:content]
      content.should =~ %r[export HOME=/var/local/u]
    end
  end

  context "when using a reverse proxy" do
    let(:params) { { 
      :jetty_forwarded => true
    }.merge(DEFAULT_PARAMS) }
    it "should enable fowarding in jetty.xml" do                                  
      content = catalogue.resource("file", "/var/local/maestro/conf/jetty.xml").send(:parameters)[:content]
      content.should =~ %r[<Set name="forwarded">true</Set>]                      
    end 
  end
end
