require 'spec_helper'

describe 'maestro' do

  it { should contain_file("/usr/local/src").with_ensure("directory") }

end
