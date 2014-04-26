class autobuntu::apps::postfix(
  $main_cf_template = "autobuntu/apps/postfix/main.cf.erb",
  $rootmail_recipient = nil
) {
  tag('provisioning')

  package { "postfix":
    ensure => present
  }->
  
  # setup postfix with our hostname
  file { "/etc/postfix/main.cf":
    ensure => file,
    content => template($main_cf_template),
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
}
