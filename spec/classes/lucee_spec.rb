require 'spec_helper'

describe 'maestro::lucee' do
  context "with default config" do
    it "should set the agent_auto_activate setting to false" do
      should contain_file('/etc/maestro_lucee.json').with_content(/"agent_auto_activate": false,$/)    
    end
  end
end
