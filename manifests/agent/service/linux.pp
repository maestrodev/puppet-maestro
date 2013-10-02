class maestro::agent::service::linux(
  $enabled     = $maestro::agent::enabled
) {

  service { 'maestro-agent':
    ensure  => $enabled ? { true => running, false => stopped },
    enable  => $enabled,
    require => [Anchor['maestro::agent::package::end'], Package['java']],
  }
}
