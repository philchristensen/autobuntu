require 'puppet'
require 'aws-sdk'

module Puppet::Parser::Functions
  newfunction(:xaz_asg_host, :type => :rvalue) do |asg_prefix|
    current_az = lookupvar('ec2_placement_availability_zone')
    
    Aws.config[:credentials] = Aws::InstanceProfileCredentials.new
    Aws.config[:region] = current_az.slice(0, -2)
    
    client = Aws::AutoScaling::Client.new
    response = client.describe_auto_scaling_instances
    
    xaz_instances = response.auto_scaling_instances.reject { |i|
      if i.health_status == "Unhealthy"
        return true
      elsif i.availability_zone == current_az
        return true
      elsif i.auto_scaling_group_name.start_with?(asg_prefix)
        return true
    }
    
    if(xaz_instances.empty?)
      fail("There aren't any suitable instances in your AutoScaling Group.")
    end

    xaz_instances.sample
  end
end