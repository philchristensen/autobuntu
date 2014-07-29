module Puppet::Parser::Functions
  newfunction(:parallel_host, :type => :rvalue) do |args|
    type, index, environ, domain = args
    fqdn = lookupvar('fqdn')
    t, i, e, d = fqdn.match(/^(\w+)(\d+)\-([^.]+)\.(.*)$/i).captures
    type = type || t
    index = index || i
    environ = environ || e
    domain = domain || d
    return "#{type}#{index}-#{environ}.#{domain}"
  end
end
