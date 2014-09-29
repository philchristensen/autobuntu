require 'puppet'
require 'aws-sdk'

module Puppet::Parser::Functions
  newfunction(:xaz_asg_host, :type => :rvalue) do |args|
    id = lookupvar('ec2_instance_id')
    az = lookupvar('ec2_placement_availability_zone')
    
    Aws.config[:credentials] = Aws::InstanceProfileCredentials.new
    Aws.config[:region] = az.slice(0, -2)
    
    client = Aws::AutoScaling::Client.new
    response = client.describe_auto_scaling_instances
    valid_instances = response.auto_scaling_instances.reject { |instance|
      if instance.instance_id == id:
        return true
      elsif instance.availability_zone == az
    }
    return valid_instances.sample
  end
end