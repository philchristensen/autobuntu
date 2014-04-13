# openssl_version.rb

Facter.add("openssl_version") do
  setcode do
    Facter::Util::Resolution.exec("dpkg -s openssl | grep Version | cut -d ' ' -f 2")
  end
end