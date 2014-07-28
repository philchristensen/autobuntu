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
  
  autobuntu::development::python::pip::package { "graphite-zope-interface":
    ensure => present,
    package => "zope.interface",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-twisted":
    ensure => present,
    package => "twisted",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-txamqp":
    ensure => present,
    package => "txamqp",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-mysqldb":
    ensure => present,
    package => "mysql-python",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-django":
    ensure => "1.5.8",
    package => "django",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-django-tagging":
    ensure => present,
    package => "django-tagging",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-web":
    ensure => present,
    package => "graphite-web",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  file { "graphite-logs":
    ensure => directory,
    path => "/opt/graphite/storage",
    recurse => true,
    owner => 'www-data',
    group => 'staff'
  }->
  
  file { "graphite-carbon-conf":
    ensure => file,
    path => "/opt/graphite/conf/carbon.conf",
    content => template("autobuntu/stats/graphite/carbon.conf.erb"),
    owner => 'root',
    group => 'staff'
  }->

  file { "graphite-carbon-storage-schemas":
    ensure => file,
    path => "/opt/graphite/conf/storage-schemas.conf",
    content => template("autobuntu/stats/graphite/storage-schemas.conf.erb"),
    owner => 'root',
    group => 'staff'
  }->

  autobuntu::development::python::django::syncdb { "graphite-syncdb":
    pythonpath => "/opt/graphite/virtualenv/bin/python",
    projectpath => "/opt/graphite/webapp/graphite"
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