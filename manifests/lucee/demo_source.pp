define maestro::lucee::demo_source(
  $source_config = {},
  $manage_type = false) {
    
  $source_dir = "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/sources"
  $source_file = "${source_dir}/${name}.json"
  
  if $manage_type {
    file { "${maestro::maestro::homedir}/apps/lucee/WEB-INF/config/demo/source_types/${name}.json":
      source =>  "puppet:///maestro/lucee/demo/source_types/${name}.json",
      owner   => $maestro::params::user,
      group   => $maestro::params::group,
      mode    => '0644',
      before  => [Service['maestro'], File["${source_file}"]],
      require => Class['maestro::maestro::config'],
    }
  }
  
  file { "${source_dir}":
    ensure  => directory,
    owner   => $maestro::params::user,
    group   => $maestro::params::group,
    mode    => '0644',
    require => Class['maestro::maestro::config'],
  } ->
  file { "${source_file}":
    owner   => $maestro::params::user,
    group   => $maestro::params::group,
    mode    => '0644',
    before  => Service['maestro'],
    content => template("maestro/lucee/demo/sources/${name}.json.erb"),
  }
}
