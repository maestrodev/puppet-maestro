require 'spec_helper'
require 'pp'

describe 'maestro::maestro::db' do
  let(:facts) { {
      :osfamily => 'RedHat',
      :postgres_default_version => '8.4',
  } }
  let(:params) { {
    :version     => '',
    :db_password => 'defaultpassword',
  } }

  context "with default postgres version" do
    it { should contain_class('postgresql::params').with_version('8.4') }
  end

  context "with custom postgres version" do
    let(:params) { {
      :version => '9.0',
      :db_password => 'defaultpassword',
    } }

    it { should contain_class('postgresql::params').with_version('9.0') }
    it { should contain_yumrepo('postgresql-repo').with_name('postgresql-9.0')}

  end
end
