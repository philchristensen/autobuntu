class autobuntu::system::motd {
  tag('provisioning')
  
  file { "/etc/update-motd.d/10-help-text":
    ensure => absent
  }
  
  file { "/etc/update-motd.d/50-landscape-sysinfo":
    ensure => file,
    source => "puppet:///modules/autobuntu/system/motd/landscape-sysinfo.wrapper",
    owner => "root",
    group => "staff",
    mode => "0755"
  }
  
  file { "/etc/update-motd.d/51-cloudguest":
    ensure => absent
  }
}