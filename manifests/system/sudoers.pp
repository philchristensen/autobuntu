class autobuntu::system::sudoers {
  tag('provisioning')

  file { "/etc/sudoers.d/99-sudo-environment":
    ensure => file,
    content => "%sudo-${environment} ALL=(ALL) ALL",
    owner => 'root',
    group => 'root',
    mode => '0440',
  }

  $host_type = regsubst($hostname, "^([a-zA-Z]+)([0-9]*)-${environment}$", '\1')
  if($host_type == ''){
    fail("Unrecognized host_type: ${host_type}")
  }
  
  file { "/etc/sudoers.d/98-sudo-host":
    ensure => file,
    content => "%sudo-${host_type} ALL=(ALL) ALL",
    owner => 'root',
    group => 'root',
    mode => '0440',
  }
}
