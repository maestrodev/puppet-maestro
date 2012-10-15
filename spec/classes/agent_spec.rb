require 'spec_helper'

describe 'maestro::agent' do

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
    let(:facts) {{:rvm_installed => 'true'}}
    it { should contain_user(DEFAULT_USER).with_groups(['root', 'rvm']) }
  end

  context "when not using rvm" do
    let(:facts) {{:rvm_installed => 'false'}}
    it { should contain_user(DEFAULT_USER).with_groups('root') }
  end

  context "when rvm fact is not set" do
    it { should contain_user(DEFAULT_USER).with_groups('root') }
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
    let(:facts) { {:operatingsystem => 'CentOS', :kernel => 'Linux', :osfamily => 'RedHat'} }
    let(:params) { DEFAULT_AGENT_PARAMS }

    it { should contain_file("/etc/init.d/maestro-agent") }
    it { should_not contain_file("/Library/LaunchDaemons/com.maestrodev.agent.plist") }
    it { should contain_service("maestro-agent") }
    it { should contain_exec("maestro-agent-memory-max").with(
      'command' => "sed -i 's/^#wrapper\\.java\\.maxmemory=.*$/wrapper\\.java\\.maxmemory=128/' /usr/local/maestro-agent/conf/wrapper.conf"
    )}
  end

  # ================================================ OS X ================================================

  context "when running on OS X" do
    let(:facts) { {:operatingsystem => 'Darwin', :kernel => 'Darwin', :osfamily => 'Darwin'} }
    let(:params) { DEFAULT_AGENT_PARAMS }

    it { should_not contain_file("/etc/init.d/maestro-agent") }
    it { should contain_file("/Library/LaunchDaemons/com.maestrodev.agent.plist") }
    it { should contain_service("maestro-agent") }
    it { should contain_exec("maestro-agent-memory-max").with(
      'command' => "sed -i '' 's/^#wrapper\\.java\\.maxmemory=.*$/wrapper\\.java\\.maxmemory=128/' /usr/local/maestro-agent/conf/wrapper.conf"
    )}
  end

  # ================================================ Windows ================================================

  context "when running on Windows" do
    let(:facts) { {:operatingsystem => 'windows', :kernel => 'windows', :osfamily => 'windows'} }
    let(:params) { DEFAULT_AGENT_PARAMS }
  end
  
  
  
  
end
