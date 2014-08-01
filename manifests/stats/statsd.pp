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
    dirname => "current"
  }->
  
  file { "/opt/statsd/current/config.js":
    ensure => file,
    source => $statsd_conf_source,
    owner => 'root',
    group => 'staff'
  }
}