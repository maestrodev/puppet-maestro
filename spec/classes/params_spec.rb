require 'spec_helper'

describe 'maestro::params' do
  context "when using default username and home directory" do
    it { should contain_user("maestro").with_home("/var/local/maestro") }
  end

  context "when using custom username and default home directory" do
    let(:params) { {
        :user => 'u'
    } }
    it { should contain_user("u").with_home("/var/local/u") }
  end

  context "when using custom username and home directory" do
    let(:params) { {
        :user => 'u',
        :user_home => '/home/u'
    } }
    it { should contain_user("u").with_home("/home/u") }
  end
end
