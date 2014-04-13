class autobuntu::system::ssh(
  $ssh_password_auth = false
){
  $password_auth = $ssh_password_auth ? {
    true => 'yes',
    default => 'no'
  }
  
  augeas { "sshd-config":
    context => "/files/etc/ssh/sshd_config",
    changes => ["set PasswordAuthentication ${ssh_password_auth}"],
    notify => Service['ssh']
  }

  service { "ssh":
    ensure => running,
    enable => true
  }
}