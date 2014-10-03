class autobuntu::stats::graphite(
  $carbon_conf_source = "puppet:///modules/autobuntu/stats/graphite/carbon.conf",
  $relay_rules_source = "puppet:///modules/autobuntu/stats/graphite/relay-rules.conf",
  $local_settings_class = nil
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
  
  file { "/opt/graphite/requirements.txt":
    ensure => file,
    content => join([
      "-e git://github.com/mozilla/elasticutils.git#egg=ceres",
      "Django==1.5.8",
      "MySQL-python==1.2.5",
      "Twisted==11.0.1",
      "argparse==1.2.1",
      "cairocffi==0.6",
      "cffi==0.8.6",
      "distribute==0.6.24",
      "django-tagging==0.3.2",
      "pycparser==2.10",
      "setuptools-git==1.1",
      "txAMQP==0.6.2",
      "whisper==0.9.12",
      "wsgiref==0.1.2",
      "zope.interface==4.1.1"
    ], "\n"),
    owner => 'root',
    group => 'staff'
  }->
  
  autobuntu::development::python::pip::requirements { "graphite-requirements":
    ensure => present,
    pip_path => "/opt/graphite/virtualenv/bin/pip",
    requirements => "/opt/graphite/requirements.txt"
  }->
  
  file { "/opt/graphite/virtualenv/local/lib/python2.7/site-packages/cairo.py":
    ensure => file,
    content => "from cairocffi import *\n"
  }->
  
  exec { "install-graphite":
    command => "/opt/graphite/virtualenv/bin/pip install graphite-web",
    creates => "/opt/graphite/webapp"
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
  }

  if($local_settings_class != nil){
    class { $local_settings_class:
      before => Autobuntu::Development::Python::Django::Syncdb['graphite-syncdb']
    }
  }

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