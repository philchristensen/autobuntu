class autobuntu::stats::graphite(
  $carbon_conf_source = "puppet:///modules/autobuntu/stats/graphite/carbon.conf",
  $relay_rules_source = "puppet:///modules/autobuntu/stats/graphite/relay-rules.conf"
){
  include apache
  
  package { ["libcairo2", "libcairo2-dev", "libffi-dev"]:
    ensure => present
  }->
  
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
  
  autobuntu::development::python::pip::package { "graphite-cairo":
    ensure => present,
    package => "cairocffi",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-zope-interface":
    ensure => present,
    package => "zope.interface",
    pip_path => "/opt/graphite/virtualenv/bin/pip",
  }->
  
  autobuntu::development::python::pip::package { "graphite-twisted":
    ensure => "11.1.0",
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
  
  file { "/opt/graphite/virtualenv/local/lib/python2.7/site-packages/cairo.py":
    ensure => file,
    content => "from cairocffi import *\n"
  }->
  
  file { ["/opt/graphite/storage",
          "/opt/graphite/storage/log",
          "/opt/graphite/storage/log/webapp"]:
    ensure => directory,
    owner => 'www-data',
    group => 'staff'
  }->
  
  file { "graphite-carbon-conf":
    ensure => file,
    path => "/opt/graphite/conf/carbon.conf",
    source => $carbon_conf_source,
    owner => 'root',
    group => 'staff',
    notify => [Service['carbon-cache'], Service['carbon-relay']]
  }->

  file { "graphite-carbon-cache-init":
    ensure => file,
    path => "/etc/init.d/carbon-cache",
    source => "puppet:///modules/autobuntu/stats/graphite/init.sh",
    owner => 'root',
    group => 'staff',
    mode => 0755,
    notify => Service['carbon-cache']
  }->

  file { "graphite-carbon-relay-rules-conf":
    ensure => file,
    path => "/opt/graphite/conf/relay-rules.conf",
    source => $relay_rules_source,
    owner => 'root',
    group => 'staff',
    notify => Service['carbon-relay']
  }->

  file { "graphite-carbon-relay-init":
    ensure => file,
    path => "/etc/init.d/carbon-relay",
    source => "puppet:///modules/autobuntu/stats/graphite/relay-init.sh",
    owner => 'root',
    group => 'staff',
    mode => 0755,
    notify => Service['carbon-relay']
  }->

  file { "graphite-carbon-storage-schemas":
    ensure => file,
    path => "/opt/graphite/conf/storage-schemas.conf",
    content => template("autobuntu/stats/graphite/storage-schemas.conf.erb"),
    owner => 'root',
    group => 'staff'
  }->

  file { "graphite-carbon-storage-aggregation":
    ensure => file,
    path => "/opt/graphite/conf/storage-aggregation.conf",
    content => template("autobuntu/stats/graphite/storage-aggregation.conf.erb"),
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
  
  apache::vhost { "graphite-${environment}.dramonline.net":
    priority => "10",
    vhost_name => $ipaddress,
    servername => "graphite-${environment}.dramonline.net",
    serveraliases => [],
    ssl => false,
    port => "80",
    template => 'autobuntu/stats/graphite/vhost.conf.erb',
    docroot => "/var/www/"
  }
  
  service { "carbon-cache":
    ensure => running,
    enable => true
  }
  
  service { "carbon-relay":
    ensure => running,
    enable => true
  }
}