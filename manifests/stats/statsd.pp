class autobuntu::stats::statsd(){
  include nodejs
  
  file { "/opt/statsd":
    ensure => directory
  }->
  
  autobuntu::development::git::checkout { "statsd":
    url => "https://github.com/etsy/statsd.git",
    path => "/opt/statsd",
    dirname => "current"
  }->
  
  file { "/opt/statsd/current/config.js":
    ensure => file,
    source => "puppet:///modules/autobuntu/stats/statsd/config.js",
  }
}