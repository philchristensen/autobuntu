class autobuntu::development::python {
  tag('provisioning')
  
  package { ["python", "python-dev", "python-pip", "python-virtualenv"]:
    ensure => present
  }

  autobuntu::development::python::pip::package { "setuptools-git":
    ensure => present,
    package => "setuptools-git",
    pip_path => "/usr/bin/pip",
    require => Package["python-pip"]
  }
  
  autobuntu::development::python::pip::package { "distribute":
    ensure => latest,
    package => "distribute",
    pip_path => '/usr/bin/env pip'
  }
}

define autobuntu::development::python::virtualenv($basename, $location) {
  include autobuntu::development::python
  
  exec { "mkvirtualenv/${location}/${name}":
    command => "virtualenv ${basename}",
    creates => "${location}/${basename}",
    cwd => $location,
    logoutput => on_failure,
    path => ['/usr/bin'],
    require => Package["python-virtualenv"]
  }->

  autobuntu::development::python::pip::package { "distribute/${location}/${name}":
    ensure => present,
    package => "distribute",
    pip_path => "${location}/${basename}/bin/pip",
    require => Package["python-pip"]
  }
}

define autobuntu::development::python::buildout($location){
  include autobuntu::development::python
  
  exec { "bootstrap/${location}":
    command => "python bootstrap.py",
    creates => "${location}/bin/buildout",
    cwd => $location,
    logoutput => on_failure,
    path => ['/usr/bin']
  }

  exec { "buildout/${location}":
    command => "python -S bin/buildout",
    creates => "${location}/.installed.cfg",
    cwd => $location,
    logoutput => on_failure,
    path => ['/usr/bin'],
    require => Exec["bootstrap/${location}"]
  }
}
