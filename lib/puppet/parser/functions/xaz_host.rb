module Puppet::Parser::Functions
  newfunction(:xaz_host, :type => :rvalue) do |args|
    type, index, environ, domain = args
    fqdn = lookupvar('fqdn')
    t, i, e, d = fqdn.match(/^(\w+)(\d+)\-([^.]+)\.(.*)$/i).captures
    type = type || t
    index = index || i
    environ = environ || e
    domain = domain || d
    
    index = (index == 1 ? 2 : 1)
    
    return "#{type}#{index}-#{environ}.#{domain}"
  end
end
