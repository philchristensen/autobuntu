class autobuntu::development::nodejs {
  include nodejs
  
  package { "npm":
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