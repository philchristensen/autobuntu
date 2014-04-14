class autobuntu::development::jenkins {
  tag('provisioning')

  include apt
  include apache
  include apache::mod::proxy
  include apache::mod::proxy_http

  apt::source { "jenkins":
    location          => "http://pkg.jenkins-ci.org/debian",
    release           => "binary/",
    repos             => "",
    key               => "D50582E6",
    key_source        => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
    pin               => "800",
    include_src       => false
  }

  # non-SSL host is meant to be just a redirect to the HTTPS side.
  apache::vhost { $fqdn:
    priority => "10",
    vhost_name => $ipaddress,
    servername => $fqdn,
    ssl => false,
    port => "80",
    template => 'autobuntu/development/jenkins/vhost.conf.erb',
    docroot => "/var/www/"
  }
  
  # SSL host is the real front door
  apache::vhost { "${fqdn}-secure":
    priority => "10",
    vhost_name => $ipaddress,
    servername => $fqdn,
    ssl => true,
    port => "443",
    template => 'autobuntu/development/jenkins/vhost.conf.erb',
    docroot => "/var/www/"
  }
  
  # Manage HTTP/AJP and port settings
  file { "jenkins-default":
    ensure => file,
    path => "/etc/default/jenkins",
    source => "puppet:///modules/autobuntu/development/jenkins/jenkins-default.sh"
  }

  package{ "jenkins":
    ensure => present,
    require => Apt::Source["jenkins"]
  }

  file { "jenkins-tmp":
    ensure => directory,
    owner => 'jenkins',
    group => 'nogroup',
    recurse => false,
    path => '/var/lib/jenkins/tmp'
  }->

  service { "jenkins":
    ensure => running,
    enable => true,
    require => [
      File["jenkins-default"],
      Package["jenkins"],
    ] 
  }

  file { "jenkins-ssh-dir":
    ensure => directory,
    path => "/var/lib/jenkins/.ssh",
    owner => "jenkins",
    group => "nogroup",
    mode => "0700"
  }->

  file { "jenkins-ssh-config":
    path => "/var/lib/jenkins/.ssh/config",
    source => "puppet:///modules/autobuntu/development/jenkins/ssh_config",
    owner => "jenkins",
    group => "nogroup",
    mode => "0700"
  }
}
