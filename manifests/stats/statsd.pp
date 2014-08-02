class autobuntu::stats::statsd(
  $statsd_conf_source = "puppet:///modules/autobuntu/stats/statsd/config.js",
  $proxy_conf_source = "puppet:///modules/autobuntu/stats/statsd/proxyConfig.js"
){
  include autobuntu::development::nodejs
  
  file { "/opt/statsd":
    ensure => directory,
    owner => 'root',
    group => 'staff'
  }->
  
  autobuntu::development::git::checkout { "statsd":
    url => "https://github.com/etsy/statsd.git",
    path => "/opt/statsd",
    dirname => "current",
    revision => "1590bcf56ea1a3ac167f62fba3d599b65582d5ea"
  }->
  
  nodejs::npm { '/opt/statsd/current:hashring':
    ensure  => present,
  }->
  
  file { "/opt/statsd/current/config.js":
    ensure => file,
    source => $statsd_conf_source,
    owner => 'root',
    group => 'staff',
    notify => Service['statsd']
  }->
  
  file { "/opt/statsd/current/proxyConfig.js":
    ensure => file,
    source => $proxy_conf_source,
    owner => 'root',
    group => 'staff',
    notify => Service['statsd-proxy']
  }
  
  group { "statsd":
    ensure => present
  }
  
  user { "statsd":
    ensure => present,
    system => true,
    gid => "statsd",
    home => "/opt/statsd"
  }
  
  file { "/etc/init/statsd.conf":
    ensure => file,
    source => "puppet:///modules/autobuntu/stats/statsd/statsd-upstart.conf",
    notify => Service['statsd']
  }
  
  service { "statsd":
    ensure => running,
    enable => true,
    require => User['statsd']
  }
  
  file { "/etc/init/statsd-proxy.conf":
    ensure => file,
    source => "puppet:///modules/autobuntu/stats/statsd/proxy-upstart.conf",
    notify => Service['statsd-proxy']
  }
  
  service { "statsd-proxy":
    ensure => running,
    enable => true,
    require => User['statsd']
  }
}