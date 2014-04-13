class autobuntu::apps::postfix(
  $postfix_sasl_source = nil,
  $rootmail_recipient = nil
) {
  tag('provisioning')

  package { "postfix":
    ensure => present
  }->
  
  # setup postfix with our hostname
  file { "/etc/postfix/main.cf":
    ensure => file,
    content => template("autobuntu/apps/postfix/main.cf.erb"),
    owner => "root",
    group => "root",
    mode => "0644"
  }
  
  if($rootmail_recipient != nil){
    # send root mail to devops
    mailalias { "root":
      ensure => present,
      recipient => $rootmail_recipient,
      target => "/etc/aliases"
    }
  
    # set mailname to FQDN
    file { "/etc/mailname":
      ensure => file,
      content=> $fqdn,
      owner => "root",
      group => "root",
      mode => "0644",
    }
  }
    
  if($postfix_sasl_source != nil){
    # setup plaintext passwords for GMail outgoing
    file { "/etc/postfix/sasl_passwd":
      ensure => file,
      path => "/etc/postfix/sasl_passwd",
      source => $postfix_sasl_source,
      owner => "root",
      group => "root",
      mode => "0644",
      require => File['/etc/mailname']
    }->

    # setup hashed passwords for sasl outgoing
    exec { "postmap-sasl-passwd":
      command => "postmap /etc/postfix/sasl_passwd",
      path => ['/usr/sbin'],
    }->

    # remove plaintext passwords file
    exec { "clear-sasl-passwd":
      command => "rm /etc/postfix/sasl_passwd",
      path => ['/bin'],
    }
  }
}
