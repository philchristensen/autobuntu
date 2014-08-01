class autobuntu::stats::statsd(
  $statsd_conf_source = "puppet:///modules/autobuntu/stats/statsd/config.js"
){
  include nodejs
  
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
  
  file { "/opt/statsd/current/config.js":
    ensure => file,
    source => $statsd_conf_source,
    owner => 'root',
    group => 'staff',
    notify => Service['statsd']
  }
  
  file { "/etc/init/statsd":
    ensure => file,
    source => "puppet:///modules/autobuntu/stats/statsd/upstart.conf",
    notify => Service['statsd']
  }
  
  service { "statsd":
    ensure => running,
    enable => true,
    provider => upstart
  }
}