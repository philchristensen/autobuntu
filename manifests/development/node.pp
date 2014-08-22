class autobuntu::development::node {
  class { 'nodejs':
    manage_repo => true
  }
  
  package { "nodejs-legacy":
    ensure => present
  }

  file { "/etc/npmrc":
    ensure => file,
    content => "registry=http://registry.npmjs.org/\n",
    owner => 'root',
    group => 'staff',
    mode => '755'
  }
}