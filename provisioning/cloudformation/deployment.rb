#!/usr/bin/env ruby

require 'cfndsl'

CloudFormation do
  Description 'Deployment of the AWS DevSecOps Workshop application.'

  Parameter(:AmazonLinuxAMI) do
    Description 'Amazon Linux AMI to deploy with.'
    Type 'AWS::EC2::Image::Id'
    # Default: Amazon Linux AMI 2016.09.0 (HVM), SSD Volume Type
    Default 'ami-c481fad3'
  end

  Parameter(:InstanceType) do
    Description 'EC2 Instance Type to deploy.'
    Type 'AWS::EC2::Subnet::Id'
    Default 't2.micro'
  end

  Parameter(:VPCID) do
    Description 'Amazon VPC ID to deploy infrastructure into.'
    Type 'AWS::EC2::VPC::Id'
  end

  Parameter(:SubnetId) do
    Description 'Subnet ID to deploy infrastructure into.'
    Type 'AWS::EC2::Subnet::Id'
  end

  Parameter(:KeyPairName) do
    Description 'Optional EC2 Keypair to use for the deployed EC2 instance.'
    Type 'AWS::EC2::KeyPair::KeyName'
    Default ''
  end

  Parameter(:Environment) do
    Description 'The environment name of this deployment.'
    Type 'String'
    AllowedValues %w(acceptance production)
  end

  Condition :IsProduction, FnEquals(Ref(:Environment), 'production')
  Condition :IsAcceptance, FnEquals(Ref(:Environment), 'acceptance')

  EC2_SecurityGroup(:SecurityGroup) do
    Condition :IsAcceptance
    VpcId Ref(:VPCID)
    GroupDescription 'SSH and HTTP access for acceptance testing.'
    SecurityGroupIngress [
      {
        IpProtocol: 'tcp',
        FromPort: '80',
        ToPort: '80',
        CidrIp: '0.0.0.0/0'
      },
      {
        IpProtocol: 'tcp',
        FromPort: '22',
        ToPort: '22',
        CidrIp: '0.0.0.0/0'
      }
    ]
  end

  EC2_SecurityGroup(:SecurityGroup) do
    Condition :IsProduction
    VpcId Ref(:VPCID)
    GroupDescription 'HTTP access for deployment.'
    SecurityGroupIngress [
      {
        IpProtocol: 'tcp',
        FromPort: '80',
        ToPort: '80',
        CidrIp: '0.0.0.0/0'
      }
    ]
  end

  CloudFormation_WaitConditionHandle(:WaitHandle)

  CloudFormation_WaitCondition(:EC2Waiter) do
    DependsOn Ref(:WebServer)
    Handle Ref(:WaitHandle)
    Timeout '300'
  end

  EC2_Instance(:WebServer) do
    ImageId Ref(:AmazonLinuxAMI)
    InstanceType Ref(:InstanceType)
    KeyName Ref(:KeyPairName)
    NetworkInterfaces [
      {
        AssociatePublicIpAddress: true,
        DeleteOnTermination: true,
        SubnetId: Ref(:SubnetId),
        DeviceIndex: 0,
        GroupSet: [
          Ref(:SecurityGroup)
        ]
      }
    ]
    Tags [
      {
        Key: 'Name',
        Value: FnJoin(' - ', ['AWS DevSecOps Workshop', Ref(:Environment)])
      },
      {
        Key: 'Environment',
        Value: Ref(:Environment)
      }
    ]

    wait_handle = [
      "#!/bin/bash\n",
      'export wait_handle="', Ref(:WaitHandle), "\"\n"
    ]

    script_path = 'provisioning/cloudformation/userdata.sh'
    script_data = File.read(script_path).split("\n").map { |line| line + "\n" }

    UserData FnBase64(FnJoin('', wait_handle + script_data))
  end

  Output(:EC2PublicIP, FnGetAtt(:WebServer, 'PublicIp'))
end
