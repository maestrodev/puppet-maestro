define maestro::lucee::demo_source(
  $source_config = {},
  $manage_type = false) {
    
  $source_file = "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/sources/${name}.json"
  
  if $manage_type {
    file { "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/source_types/${name}.json":
      source =>  "puppet:///maestro/lucee/demo/source_types/${name}.json",
      owner   => $maestro::params::user,
      group   => $maestro::params::group,
      mode    => '0644',
      before  => [Service['maestro'], File["${source_file}"]],
      require => File['/etc/maestro_lucee.json'],
    }
  }
  
  file { "${source_file}":
    owner   => $maestro::params::user,
    group   => $maestro::params::group,
    mode    => '0644',
    before  => Service['maestro'],
    require => File['/etc/maestro_lucee.json'],
    content => template("maestro/lucee/demo/sources/${name}.json.erb"),
  }
}