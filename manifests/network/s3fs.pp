class autobuntu::network::s3fs {
  package { ["build-essential", "libfuse-dev", "fuse-utils", "libcurl4-openssl-dev",
             "libxml2-dev", "mime-support", "automake", "libtool"]:
   ensure => present
  }->
  
  file { "/opt/s3fs":
    ensure => directory
  }->
  
  staging::file { "s3fs-latest.zip":
    source => "https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip"
  }->
  
  staging::extract { "s3fs-latest.zip":
    target => "/opt/s3fs",
    creates => "/opt/s3fs/s3fs-fuse-master",
  }->
  
  exec { "s3fs-autogen":
    cwd => "/opt/s3fs/s3fs-fuse-master",
    command => "/opt/s3fs/s3fs-fuse-master/autogen.sh",
    creates => "/opt/s3fs/s3fs-fuse-master/configure"
  }->
  
  exec { "s3fs-configure":
    cwd => "/opt/s3fs/s3fs-fuse-master",
    command => "/opt/s3fs/s3fs-fuse-master/configure",
    creates => "/opt/s3fs/s3fs-fuse-master/config.status"
  }->
  
  exec { "s3fs-make":
    cwd => "/opt/s3fs/s3fs-fuse-master",
    command => "/usr/bin/make",
    creates => "/opt/s3fs/s3fs-fuse-master/src/s3fs"
  }->
  
  exec { "s3fs-make-install":
    cwd => "/opt/s3fs/s3fs-fuse-master",
    command => "/usr/bin/make install",
    creates => "/usr/local/bin/s3fs"
  }
}