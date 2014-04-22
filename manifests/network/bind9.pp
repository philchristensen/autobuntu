class autobuntu::network::bind9(
  $options_template = 'autobuntu/network/named.conf.local.erb',
  $local_template =  'autobuntu/network/named.conf.options.erb',
){
  tag('provisioning')

  service { "bind9":
    ensure => running,
    enable => true
  }
  
  package { "bind9":
    ensure => present,
  }->
  
  file { "/etc/bind/named.conf.options":
    ensure => file,
    content => template($options_template),
    owner => 'root',
    group => 'bind',
    mode => '644',
    notify => Service['bind9']
  }->
  
  file { "/etc/bind/named.conf.local":
    ensure => file,
    content => template($local_template),
    owner => 'root',
    group => 'bind',
    mode => '644',
    notify => Service['bind9']
  }->
  
  file { "/etc/bind/zones":
    ensure => directory,
  }->
  
  file { "/var/log/bind9":
    ensure => directory,
    owner => 'root',
    group => 'bind',
    mode => '0775'
  }
  
  file { "usr.sbin.named":
    ensure => file,
    path => "/etc/apparmor.d/usr.sbin.named",
    source => "puppet:///modules/autobuntu/system/apparmor/usr.sbin.named",
    owner => "root",
    group => "root",
    mode => "0644",
    require => File["/etc/apparmor.d"],
    notify => Exec["reload-apparmor_parser-named"],
  }

  exec { 'reload-apparmor_parser-named':
    command => "apparmor_parser -r /etc/apparmor.d/usr.sbin.named",
    path => ['/sbin'],
    refreshonly => true,
    notify => Service["bind9"],
    unless => "/usr/bin/which apparmor_parse"
  }
}
