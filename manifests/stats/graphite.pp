class autobuntu::stats::graphite(){
  include apache
  
  file { "/opt/graphite":
    ensure => directory,
    owner => 'root',
    group => 'staff'
  }->
  
  autobuntu::development::python::virtualenv {"graphite-virtualenv":
    basename => "virtualenv",
    location => "/opt/graphite"
  }->
  
  autobuntu::development::python::pip::package { "graphite-setuptools-git":
    ensure => present,
    package => "setuptools-git",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->

  autobuntu::development::python::pip::package { "graphite-ceres":
    ensure => present,
    package => "https://github.com/graphite-project/ceres/tarball/master",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-whisper":
    ensure => present,
    package => "whisper",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-carbon":
    ensure => present,
    package => "carbon",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-web":
    ensure => present,
    package => "graphite-web",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  file { "graphite-logs":
    ensure => directory,
    path => "/opt/graphite/storage/logs/webapp",
    owner => 'www-data',
    group => 'staff'
  }->
  
  file { "graphite-wsgi":
    ensure => file,
    path => "/opt/graphite/conf/graphite.wsgi.py",
    content => template("autobuntu/stats/graphite/wsgi.py.erb"),
    owner => 'root',
    group => 'staff'
  }->
  
  apache::vhost { 'stats.dramonline.net':
    priority => "10",
    vhost_name => $ipaddress,
    servername => 'stats.dramonline.net',
    ssl => false,
    port => "80",
    template => 'autobuntu/stats/graphite/vhost.conf.erb',
    docroot => "/var/www/"
  }
  

}