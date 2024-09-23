# controls/aws_security_group_tests.rb

# Use environment variables for VPC ID and Instance ID
vpc_id = ENV['VPC_ID']
instance_id = ENV['INSTANCE_ID']

control 'aws-security-group-1.0' do
  impact 1.0
  title 'Ensure the custom security group exists'
  describe aws_security_group('custom-security-group') do
    it { should exist }
    its('description') { should eq 'Custom security group in the default VPC' }
    its('vpc_id') { should eq vpc_id }
  end

  # Ingress rules
  describe aws_security_group('custom-security-group').ingress_rules do
    it { should include(
      {
        'from_port' => 8080,
        'to_port' => 8080,
        'protocol' => 'tcp',
        'cidr_blocks' => ['0.0.0.0/0']
      }
    )}
    
    it { should include(
      {
        'from_port' => 22,
        'to_port' => 22,
        'protocol' => 'tcp',
        'cidr_blocks' => ['0.0.0.0/0']
      }
    )}
  end

  # Egress rules
  describe aws_security_group('custom-security-group').egress_rules do
    it { should include(
      {
        'from_port' => 0,
        'to_port' => 0,
        'protocol' => '-1',
        'cidr_blocks' => ['0.0.0.0/0']
      }
    )}
  end
end

control 'aws-ec2-instance-1.0' do
  impact 1.0
  title 'Ensure the EC2 instance exists and is configured correctly'
  
  describe aws_ec2_instance(instance_id) do
    it { should exist }
    its('instance_type') { should eq 't2.micro' } 
    its('image_id') { should eq 'ami-0d1e92463a5acf79d' } 
    its('key_name') { should eq 'deploy' } 
    its('security_group_ids') { should include 'custom-security-group' }
  end
end
