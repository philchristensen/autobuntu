# Standard resources to be installed on *every* machine managed by Puppet.
class autobuntu::common(
  $short_label,
  $domain
){
  tag('provisioning')

  require autobuntu::system::apt
  require autobuntu::system::apparmor
  require autobuntu::system::sudoers
  require autobuntu::system::openssl
  require autobuntu::system::ssh
  
  include autobuntu::system::motd
  include autobuntu::apps::bash
  
  # standard packages
  package { ["libaugeas-ruby", "augeas-tools", "logrotate", "sysstat", "tree",
              "sudo", "unzip", "curl", "lynx", "s3cmd", "apg"]:
    ensure => present
  }
  
  package { 'bundler':
    ensure => present,
    provider => gem
  }
  
  # force set the hostname, even if PTR is broken
  file { "/etc/rc.local":
    ensure => file,
    content => template("autobuntu/common/rc.local.erb"),
    owner => "root",
    group => "root",
    mode => "0755"
  }

  include autobuntu::apps::tmpreaper
  include autobuntu::apps::ntp
  include autobuntu::apps::postfix

  include autobuntu::languages::python
}
