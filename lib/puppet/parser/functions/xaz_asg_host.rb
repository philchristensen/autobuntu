require 'puppet'
require 'aws-sdk'

module Puppet::Parser::Functions
  newfunction(:xaz_asg_host, :type => :rvalue) do |asg_prefix, domain|
    Aws.config[:credentials] = Aws::InstanceProfileCredentials.new
    Aws.config[:region] = current_az[0,current_az.length-1]

    as_client = Aws::AutoScaling::Client.new
    response = as_client.describe_auto_scaling_instances
    xaz_instances = response.auto_scaling_instances.select do |i|
      i.health_status.downcase != "unhealthy" &&
      i.availability_zone != current_az &&
      i.auto_scaling_group_name.start_with?(asg_prefix)
    end

    ec2_client = Aws::EC2::Client.new
    xaz_instance_id = xaz_instances.sample.instance_id
    response = ec2_client.describe_tags(
      :filters => [{
        :name => 'resource-id',
        :values => [xaz_instance_id]
      }]
    )
    name_tag = response.tags.select { |t| t.key == 'Name' }
    name_tag[0].value + '.' + domain
  end
end