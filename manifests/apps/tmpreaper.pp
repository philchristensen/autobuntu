class autobuntu::apps::tmpreaper {
  tag('provisioning')

  package { 'tmpreaper':
    ensure => present
  }->
  
  file { '/etc/tmpreaper.conf':
    ensure => present,
    source => "puppet:///modules/autobuntu/apps/tmpreaper/tmpreaper.conf",
    owner => "root",
    group => "root",
    mode => "0644",
  }->
  
  # tmpreaper runs once a day on tmp dir
  cron { 'clean-tmp-files':
    command =>  '/usr/sbin/tmpreaper 24h /tmp',
    user =>  root,
    hour =>  22,
    minute =>  22,
  }->  
  
  # tmpreaper runs once a day on puppet reports dir
  cron { 'clean-puppet-reports':
    command =>  'test -d /var/lib/puppet/reports && /usr/sbin/tmpreaper 2d /var/lib/puppet/reports',
    user =>  root,
    hour =>  21,
    minute =>  22,
  }
}
