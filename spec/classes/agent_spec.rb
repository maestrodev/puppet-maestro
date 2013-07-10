require 'spec_helper'

describe 'maestro::agent' do
  include_context :centos

  DEFAULT_AGENT_PARAMS = {
      :repo => {
          'id' => 'maestro-mirror',
          'username' => 'u',
          'password' => 'p',
          'url' => 'https://repo.maestrodev.com/archiva/repository/all'
      },
      :agent_version => '1.0',
  }

  DEFAULT_USER = "maestro_agent"
  
  let(:params) { DEFAULT_AGENT_PARAMS }
  
  it { should contain_file("/var/local/maestro-agent").with(
    :ensure => :directory,
    :owner  => DEFAULT_USER)
  }

  # context "when using custom basedir" do
  #   let(:params) { DEFAULT_PARAMS.merge({
  #     :basedir => '/tmp/maestro-agent',
  #   }) }
  #   it { should contain_exec("agent").with_cwd('/tmp') }
  # end

  context "when using rvm" do
    let(:facts) { super().merge({:rvm_installed => 'true'}) }
    it { should contain_user(DEFAULT_USER).with_groups(['root', 'rvm']) }
  end

  context "when not using rvm" do
    let(:facts) { super().merge({:rvm_installed => 'false'}) }
    it { should contain_user(DEFAULT_USER).with_groups('root') }
  end

  context "when rvm fact is not set" do
    it { should contain_user(DEFAULT_USER).with_groups('root') }
  end

  agent_config = "maestro_agent.json"
  agent_config_file = "/var/local/maestro-agent/conf/maestro_agent.json"
  context "with a default support address" do
    it { 
      should contain_file(agent_config).with_path(agent_config_file)
      content = catalogue.resource('file', agent_config).send(:parameters)[:content]
      content.should =~ %r["to": "support@maestrodev.com"]
    }
  end
  
  context "with a configured support address" do
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :support_email => "support@example.com"
    })}
    it { 
      should contain_file(agent_config).with_path(agent_config_file)
      content = catalogue.resource('file', agent_config).send(:parameters)[:content]
      content.should =~ %r["to": "support@example.com"]
    }
  end
  
  # ================================================ Tarball install =========================================

  context "when installing from a tarball" do
    it { should contain_file("/var/local") }
    
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :package_type => 'tarball'
    }) }
    it { should contain_exec("unpack-agent").with_cwd('/usr/local') }
  end

  context "when passing only agent snapshot version" do
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :agent_version => '0.1.1-20120430.110153-41',
    }) }
    it { should contain_wget__authfetch("fetch-agent").with(
      'source' => "https://repo.maestrodev.com/archiva/repository/all/com/maestrodev/lucee/agent/0.1.1-SNAPSHOT/agent-0.1.1-20120430.110153-41-bin.tar.gz",
      'destination' => "/usr/local/src/agent-0.1.1-20120430.110153-41-bin.tar.gz"
    )}
  end

  context "when passing a release version" do
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :agent_version => '0.1.1',
    }) }
    it { should contain_wget__authfetch("fetch-agent").with(
      'source' => "https://repo.maestrodev.com/archiva/repository/all/com/maestrodev/lucee/agent/0.1.1/agent-0.1.1-bin.tar.gz",
      'destination' => "/usr/local/src/agent-0.1.1-bin.tar.gz"
    )}
  end
  
  # ================================================ rpm install =========================================

  context "when installing a release version from an rpm" do
    
    it { should contain_file("/var/local") }
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :package_type => 'rpm'
    }) }
    it { should_not contain_exec("unpack-agent") }
    agent_rpm_source = "https://repo.maestrodev.com/archiva/repository/all/com/maestrodev/lucee/agent/1.0/agent-1.0-rpm.rpm"
    it { should contain_package("maestro-agent").with({'source' => "/usr/local/src/agent-1.0.rpm", 'provider' => 'rpm' } )}
    it { should contain_wget__authfetch("fetch-agent-rpm").with_source(agent_rpm_source) }
  end

  context "when installing a snapshot version from an rpm" do
    let(:params) { DEFAULT_AGENT_PARAMS.merge({
      :package_type => 'rpm',
      :agent_version => '1.0.0-20120430.110153-41',
    }) }
    it { should_not contain_exec("unpack-agent") }
    agent_rpm_source = "https://repo.maestrodev.com/archiva/repository/all/com/maestrodev/lucee/agent/1.0.0-SNAPSHOT/agent-1.0.0-20120430.110153-41-rpm.rpm"
    it { should contain_package("maestro-agent").with({'source' => "/usr/local/src/agent-1.0.0-20120430.110153-41.rpm", 'provider' => 'rpm' } )}
    it { should contain_wget__authfetch("fetch-agent-rpm").with_source(agent_rpm_source) }
  end

  # ================================================ Linux ================================================

  context "when running on CentOS" do
    let(:params) { DEFAULT_AGENT_PARAMS }

    it { should contain_file("/etc/init.d/maestro-agent") }
    it { should_not contain_file("/Library/LaunchDaemons/com.maestrodev.agent.plist") }
    it { should contain_service("maestro-agent").with({
      :ensure => 'running',
      :enable => true
    }) }
    it { should contain_augeas("maestro-agent-wrapper-maxmemory") }
  end

  # ================================================ OS X ================================================

  context "when running on OS X" do
    let(:facts) { {:operatingsystem => 'Darwin', :kernel => 'Darwin', :osfamily => 'Darwin'} }
    let(:params) { DEFAULT_AGENT_PARAMS }

    it { should_not contain_file("/etc/init.d/maestro-agent") }
    it { should contain_file("/Library/LaunchDaemons/com.maestrodev.agent.plist") }
    it { should contain_service("maestro-agent").with({
      :ensure => 'running',
      :enable => true
    }) }
    it { should contain_augeas("maestro-agent-wrapper-maxmemory") }
  end
end
