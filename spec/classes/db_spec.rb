require 'spec_helper'
require 'pp'

describe 'maestro::maestro::db' do
  DEFAULT_DB_PARAMS = {
    :db_password => "defaultpassword",
  }

  let(:facts) { {
      :osfamily => 'RedHat',
      :postgres_default_version => '8.4',
  } }
  let(:params) { DEFAULT_DB_PARAMS }

  context "with default postgres version" do
    it { should contain_class("postgresql::version").with_version("8.4") }
    it { should contain_package("postgresql-server").with_name('postgresql-server') }
  end

  context "with custom postgres version" do
    let(:params) { {
      :version => '9.0',
    }.merge DEFAULT_DB_PARAMS }

    it { should contain_class("postgresql::version").with_version("9.0") }
    it { should contain_package("postgresql-server").with_name('postgresql90-server') }
  end
end
