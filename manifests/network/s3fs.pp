class autobuntu::network::s3fs {
  package { ["build-essential", "libfuse-dev", "fuse-utils", "libcurl4-openssl-dev",
             "libxml2-dev", "mime-support", "automake", "libtool"]:
   ensure => present
  }->
  
  staging::file { "s3fs-latest.zip":
    source => "https://github.com/s3fs-fuse/s3fs-fuse/archive/master.zip"
  }->
  
  staging::extract { "s3fs-latest.zip":
    target => "/opt/s3fs",
    creates => "/opt/s3fs/s3fs-fuse-master",
  }
}