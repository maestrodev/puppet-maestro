shared_context :centos do

  let(:facts) {{
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :postgres_default_version => '8.4',
    :concat_basedir => 'tmp/concat'
  }}

end
