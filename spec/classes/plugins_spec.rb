require 'spec_helper'

describe 'maestro::plugins' do

  context "when using defaults" do
    # Test that defaults are created by picking a plugin always likely to be
    # there
    it { should contain_maestro__plugin("maestro-ssh-plugin") }
  end
end


