module Puppet::Parser::Functions
  newfunction(:parallel_host, :type => :rvalue) do |args|
    type, index, environ, domain = args
    fqdn = lookupvar('fqdn')
    match = fqdn.match(/^(\w+)(\d+)\-([^.]+)\.(.*)$/i)
    if(! match){
      fail("Can't determine parallel_host for #{fqdn}, not of the form typeN-env.example.com")
    }
    t, i, e, d = match.captures
    type = type || t
    index = index || i
    environ = environ || e
    domain = domain || d
    return "#{type}#{index}-#{environ}.#{domain}"
  end
end
