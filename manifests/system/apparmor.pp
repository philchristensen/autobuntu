class autobuntu::system::apparmor {
  tag('provisioning')

  # setup apparmor for ntpd
  file { "/etc/apparmor.d":
    ensure => directory
  }->
  
  file { "usr.sbin.ntpd":
    ensure => file,
    path => "/etc/apparmor.d/usr.sbin.ntpd",
    source => "puppet:///modules/autobuntu/system/apparmor/usr.sbin.ntpd",
    owner => "root",
    group => "root",
    mode => "0644",
    notify => Exec["reload-apparmor_parser-ntp"],
  }

  exec { 'reload-apparmor_parser-ntp':
    command => "apparmor_parser -r /etc/apparmor.d/usr.sbin.ntpd",
    path => ['/sbin'],
    refreshonly => true,
    notify => Service["ntp"],
    unless => "/usr/bin/which apparmor_parse"
  }
}
