class autobuntu::network::s3fs {
  package { ["build-essential", "libfuse-dev", "fuse-utils", "libcurl4-openssl-dev",
             "libxml2-dev", "mime-support", "automake", "libtool"]:
   ensure => present
  }->
  
  file { "/opt/s3fs":
    ensure => directory
  }->
  
  staging::file { "s3fs-fuse-1.77.tar.gz":
    source => "https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.77.tar.gz"
  }->
  
  staging::extract { "s3fs-fuse-1.77.tar.gz":
    target => "/opt/s3fs",
    creates => "/opt/s3fs/s3fs-fuse-1.77",
  }->
  
  exec { "s3fs-autogen":
    cwd => "/opt/s3fs/s3fs-fuse-1.77",
    command => "/opt/s3fs/s3fs-fuse-1.77/autogen.sh",
    creates => "/opt/s3fs/s3fs-fuse-1.77/configure"
  }->
  
  exec { "s3fs-configure":
    cwd => "/opt/s3fs/s3fs-fuse-1.77",
    command => "/opt/s3fs/s3fs-fuse-1.77/configure",
    creates => "/opt/s3fs/s3fs-fuse-1.77/config.status"
  }->
  
  exec { "s3fs-make":
    cwd => "/opt/s3fs/s3fs-fuse-1.77",
    command => "/usr/bin/make",
    creates => "/opt/s3fs/s3fs-fuse-1.77/src/s3fs",
    timeout => 0
  }->
  
  exec { "s3fs-make-install":
    cwd => "/opt/s3fs/s3fs-fuse-1.77",
    command => "/usr/bin/make install",
    creates => "/usr/local/bin/s3fs"
  }
}