require 'spec_helper'

describe 'maestro::lucee' do
  context "with default config" do
    it { should contain_file('/etc/maestro_lucee.json') }
  end
end
