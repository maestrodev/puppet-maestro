require 'spec_helper'

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

describe 'maestro::maestro' do
  let(:params) { DEFAULT_PARAMS }

  context "when using a custom home directory" do
    let(:params) { {
        :run_as_home => '/var/local/u',
    }.merge(DEFAULT_PARAMS) }
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
    let(:params) { {
        :run_as_home => '/var/local/u',
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

  context "when is_demo is configured with default log level" do
    let(:params) { {
      :is_demo => true
    }.merge(DEFAULT_PARAMS) }

    it { should contain_file("/etc/maestro_lucee.json")}
    it "should configure lucee correctly" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ %r["is_demo":true]
      content.should =~ %r["level": "DEBUG"]
    end
  end

  context "when default is_demo is configured with default log level" do
    it { should contain_file("/etc/maestro_lucee.json")}
    it "should configure lucee correctly" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ %r["is_demo":false]
      content.should =~ %r["level": "INFO"]
    end
  end

  context "when is_demo is configured with a custom log level" do
    let(:params) { {
      :is_demo => true,
      :log_level => "ERROR"
    }.merge(DEFAULT_PARAMS) }

    it { should contain_file("/etc/maestro_lucee.json")}
    it "should configure lucee correctly" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ %r["is_demo":true]
      content.should =~ %r["level": "ERROR"]
    end
  end

  context "when configured with a custom log level" do
    let(:params) { {
      :log_level => "ERROR"
    }.merge(DEFAULT_PARAMS) }

    it { should contain_file("/etc/maestro_lucee.json")}
    it "should configure lucee correctly" do
      content = catalogue.resource('file', '/etc/maestro_lucee.json').send(:parameters)[:content]
      content.should =~ %r["is_demo":false]
      content.should =~ %r["level": "ERROR"]
    end
  end
end
