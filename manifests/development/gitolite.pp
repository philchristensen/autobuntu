class autobuntu::development::gitolite {
  tag('provisioning')

  package { "gitolite":
    ensure => present
  }
  
  file { "/var/git":
    ensure => directory,
    owner => "git",
    group => "git",
    mode => "0755",
    recurse => true
  }
  
  file { "/var/git/.ssh":
    ensure => directory,
    owner => "git",
    group => "git",
    mode => "0700",
    recurse => true
  }
  
  user { "git":
    ensure => present,
    home => "/var/git",
  }

  file { "/var/git/.gitconfig":
    ensure => file,
    path => "/var/git/.gitconfig",
    owner => "git",
    group => "git",
    mode => "0775",
    content=> template("autobuntu/development/gitolite/gitconfig.ini.erb"),
  }

  file { "/var/git/.bashrc":
    ensure => file,
    content => 'PATH=$HOME/bin:$PATH',
    owner => "git",
    mode => "0755"
  }
  
  file { "/var/git/.gitolite.rc":
    ensure => file,
    content => template('autobuntu/development/gitolite/gitolite.rc.erb'),
    owner => "git",
    mode => "0755"
  }
  
  exec { "gitolite-ssh-keygen":
    command => "ssh-keygen -f /var/git/.ssh/id_rsa -N ''",
    path => ['/usr/bin'],
    user => 'git',
    creates => '/var/git/.ssh/id_rsa'
  }->
  
  exec { "gl-setup":
    command => 'gl-setup -q /var/git/.ssh/id_rsa.pub',
    environment => ["HOME=/var/git"],
    path => ['/bin', '/usr/bin'],
    user => 'git',
    cwd => '/var/git',
    creates => '/var/git/.gitolite'
  }
}
