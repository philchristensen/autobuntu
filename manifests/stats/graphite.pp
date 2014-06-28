class autobuntu::stats::graphite(){
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
  }
}