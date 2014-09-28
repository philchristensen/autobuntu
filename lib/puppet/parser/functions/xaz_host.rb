module Puppet::Parser::Functions
  newfunction(:xaz_host, :type => :rvalue) do |args|
    type, index, environ, domain = args
    fqdn = lookupvar('fqdn')
    match = fqdn.match(/^(\w+)(\d+)\-([^.]+)\.(.*)$/i)
    if(! match){
      fail("Can't determine xaz_host for #{fqdn}, not of the form typeN-env.example.com")
    }
    t, i, e, d = match.captures
    type = type || t
    index = index || i
    environ = environ || e
    domain = domain || d
    
    index = (index == "1" ? 2 : 1)
    
    return "#{type}#{index}-#{environ}.#{domain}"
  end
end
