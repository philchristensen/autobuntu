class autobuntu::development::nodejs {
  apt::ppa { 'ppa:chris-lea/node.js':
    before => Class['nodejs']
  }

  include nodejs
  
  package { "npm":
    ensure => present,
    require => Class['nodejs']
  }
  
  file { "/etc/npmrc":
    ensure => file,
    content => "registry=http://registry.npmjs.org/\n",
    owner => 'root',
    group => 'staff',
    mode => '755'
  }
}