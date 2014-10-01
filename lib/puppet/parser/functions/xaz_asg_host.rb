require 'puppet'
require 'aws-sdk'

module Puppet::Parser::Functions
  newfunction(:xaz_asg_host, :type => :rvalue) do |asg_prefix|
    current_az = lookupvar('ec2_placement_availability_zone')
    
    current_az = 'us-east-1'
    asg_prefix = 'dram-prod-app'
    
    Aws.config[:credentials] = Aws::InstanceProfileCredentials.new
    Aws.config[:region] = current_az[0,current_az.length-1]

    client = Aws::AutoScaling::Client.new
    response = client.describe_auto_scaling_instances

    xaz_instances = response.auto_scaling_instances.delete_if do |i|
      i.health_status == "unhealthy" || 
      i.availability_zone == current_az || 
      ! i.auto_scaling_group_name.start_with?(asg_prefix)
    end
    
    return xaz_instances.sample
  end
end