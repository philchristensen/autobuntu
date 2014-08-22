class autobuntu::management::foreman {
  apt::key { 'foreman':
    key        => '1AA043B8',
    key_source => 'http://deb.theforeman.org/pubkey.gpg',
  }

  apt::source { 'foreman':
    location   => 'http://deb.theforeman.org',
    release    => 'trusty',
    repos      => '1.5',
    include_src => false,
    require => Apt::Key['foreman']
  }

  apt::source { 'foreman-plugins':
    location   => 'http://deb.theforeman.org',
    release    => 'plugins',
    repos      => '1.5',
    include_src => false,
    require => Apt::Key['foreman']
  }

  package { "foreman-installer":
    ensure => present,
    require => [
        Apt::Source['foreman'],
        Apt::Source['foreman-plugins']
      ]
  }
}
