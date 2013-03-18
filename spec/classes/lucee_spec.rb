require 'spec_helper'

describe 'maestro::lucee' do

  params = {
      :config_dir          => "/var/local/maestro/conf",
      :agent_auto_activate => false,
  }

  let(:params) { params }

  context "with default config" do
    it "should set the agent_auto_activate setting to false" do
      should contain_file('/var/local/maestro/conf/maestro_lucee.json').with_content(/"agent_auto_activate": false,$/)
    end
    it "should set the is_demo setting to false" do
      should contain_file('/var/local/maestro/conf/maestro_lucee.json').with_content(/"is_demo": false,$/)
    end
    
  end
end
