class autobuntu::system::openvpn {
  package { "openvpn":
    ensure => present
  }
  
  exec { "config-easy-rsa":
    command => "/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/easy-rsa",
    creates => "/etc/openvpn/easy-rsa",
    require => Package['openvpn']
  }
}