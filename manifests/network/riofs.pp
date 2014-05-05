class autobuntu::network::riofs {
  package { ["build-essential", "automake", "autoconf", "libtool", "pkg-config", "intltool",
                     "libglib2.0-dev", "libfuse-dev", "libxml2-dev", "libevent-dev", "libssl-dev"]:
   ensure => present
  }->
  
  file { "/opt/riofs":
    ensure => directory
  }->
  
  staging::file { "riosfs-0.6.tar.gz":
    source => "https://github.com/skoobe/riofs/archive/v0.6.tar.gz"
  }->
  
  staging::extract { "riofs-0.6.tar.gz":
    target => "/opt/riofs",
    creates => "/opt/riofs/riofs-0.6",
  }->
  
  exec { "riofs-autogen":
    cwd => "/opt/riofs/riofs-0.6",
    command => "/opt/riofs/riofs-0.6/autogen.sh",
    creates => "/opt/riofs/riofs-0.6/configure"
  }->
  
  exec { "riofs-configure":
    cwd => "/opt/riofs/riofs-0.6",
    command => "/opt/riofs/riofs-0.6/configure",
    creates => "/opt/riofs/riofs-0.6/config.status"
  }->
  
  exec { "riofs-make":
    cwd => "/opt/riofs/riofs-0.6",
    command => "/usr/bin/make",
    creates => "/opt/riofs/riofs-0.6/src/riofs",
    timeout => 0
  }->
  
  exec { "riofs-make-install":
    cwd => "/opt/riofs/riofs-0.6",
    command => "/usr/bin/make install",
    creates => "/usr/local/bin/riofs"
  }
}