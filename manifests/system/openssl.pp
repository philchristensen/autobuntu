class autobuntu::system::openssl {
  $minimum_version = "1.0.1-4ubuntu5.12"
  # if the installed version of OpenSSL is less than minimum
  if(versioncmp($openssl_version, $minimum_version) == -1){
    package { "openssl":
      ensure => $minimum_version
    }
  }
}