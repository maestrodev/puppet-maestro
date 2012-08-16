require 'spec_helper'

describe 'maestro::logging' do
  context "when using default parameters" do
    it { should contain_augeas("maestro-logging").with_changes(/ INFO$/)}
  end

  context "when configured with a custom log level" do
    let(:params) { {
      :level => "ERROR"
    } }

    it { should contain_augeas("maestro-logging").with_changes(/ ERROR$/)}
  end
end
