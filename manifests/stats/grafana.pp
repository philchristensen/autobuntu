class autobuntu::stats::grafana(
  $grafana_hostname,
  $graphite_hostname
){
  include apache
  
  $grafana_version = "1.7.0"
  
  file { "/opt/grafana":
    ensure => directory,
    owner => 'root',
    group => 'staff',
    mode => '0755'
  }

  staging::deploy { "grafana-${grafana_version}.tar.gz":
    source => "http://grafanarel.s3.amazonaws.com/grafana-${grafana_version}.tar.gz",
    target => "/opt/grafana",
    creates => "/opt/grafana/grafana-${grafana_version}/index.html",
    user => 'root',
    group => 'staff'
  }
  
  file { "/opt/grafana/grafana-${grafana_version}/config.js":
    ensure => file,
    content => template("autobuntu/stats/grafana/config.js.erb"),
    owner => 'root',
    group => 'staff',
    mode => '0755'
  }
  
  apache::vhost { $grafana_hostname:
    priority => "10",
    vhost_name => $ipaddress,
    servername => $grafana_hostname,
    serveraliases => [],
    ssl => false,
    port => "80",
    template => 'autobuntu/stats/grafana/vhost.conf.erb',
    docroot => "/opt/grafana/grafana-${grafana_version}",
    notify => Service['apache2']
  }
}