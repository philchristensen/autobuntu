class autobuntu::apps::ntp {
  tag('provisioning')

  package { "ntp":
    ensure => present
  }
  
  service { "ntp":
    ensure => running,
    enable => true, 
    require => Package["ntp"]
  }
}
