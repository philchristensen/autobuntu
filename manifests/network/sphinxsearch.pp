class autobuntu::network::sphinxsearch {
  apt::ppa { 'ppa:builds/sphinxsearch-rel21': }->
  
  package { "sphinxsearch":
    ensure => present
  }->
  
  service { "sphinxsearch":
    ensure => running,
    enable => true
  }
}