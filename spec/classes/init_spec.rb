require 'spec_helper'

describe 'maestro' do
  context "when using default username and home directory" do
    it { should contain_user("maestro").with_home("/home/maestro") }
  end

  context "when using custom username and default home directory" do
    let(:params) { {
        :run_as => 'u'
    } }
    it { should contain_user("u").with_home("/home/u") }
  end

  context "when using custom username and home directory" do
    let(:params) { {
        :run_as => 'u',
        :run_as_home => '/var/local/u'
    } }
    it { should contain_user("u").with_home("/var/local/u") }
  end
end
