#!/usr/bin/env ruby

require 'cfndsl'

CloudFormation do
  Description 'AWS DevSecOps Workshop Jenkins Server'

  Parameter(:InstanceType) do
    Description 'EC2 Instance Type to deploy.'
    Type 'String'
    Default 't2.micro'
  end

  Parameter(:VPCID) do
    Description 'Amazon VPC ID to deploy Jenkins into.'
    Type 'AWS::EC2::VPC::Id'
  end

  Parameter(:SubnetId) do
    Description 'Subnet ID to deploy Jenkins into.'
    Type 'AWS::EC2::Subnet::Id'
  end

  Parameter(:WorldCIDR) do
    Description 'The CIDR block to allow HTTP access to Jenkins with.'
    Type 'String'
    Default '0.0.0.0/0'
  end

  Parameter(:GithubCIDR) do
    Description 'The CIDR block to allow HTTP access to Jenkins with.'
    Type 'String'
    # https://help.github.com/articles/what-ip-addresses-does-github-use-that-i-should-whitelist/
    Default '192.30.252.0/22'
  end

  EC2_SecurityGroup(:SecurityGroup) do
    VpcId Ref(:VPCID)
    GroupDescription 'HTTP access for deployment.'
    SecurityGroupIngress [
      {
        # Jenkins HTTP
        IpProtocol: 'tcp',
        FromPort: '8080',
        ToPort: '8080',
        CidrIp: Ref(:WorldCIDR)
      }
    ]
    SecurityGroupEgress [
      {
        # Jenkins HTTP
        IpProtocol: 'tcp',
        FromPort: '8080',
        ToPort: '8080',
        CidrIp: Ref(:WorldCIDR)
      },
      {
        # Github
        IpProtocol: 'tcp',
        FromPort: '22',
        ToPort: '22',
        CidrIp: Ref(:GithubCIDR)
      },
      {
        # Github
        IpProtocol: 'tcp',
        FromPort: '9418',
        ToPort: '9418',
        CidrIp: Ref(:GithubCIDR)
      },
      {
        # World HTTP
        IpProtocol: 'tcp',
        FromPort: '80',
        ToPort: '80',
        CidrIp: Ref(:WorldCIDR)
      },
      {
        # World HTTPS
        IpProtocol: 'tcp',
        FromPort: '443',
        ToPort: '443',
        CidrIp: Ref(:WorldCIDR)
      }
    ]
  end

  CloudFormation_WaitConditionHandle(:WaitHandle)

  CloudFormation_WaitCondition(:EC2Waiter) do
    DependsOn :JenkinsServer
    Handle Ref(:WaitHandle)
    Timeout '300'
  end

  EC2_Instance(:JenkinsServer) do
    ImageId 'ami-32114e25'
    InstanceType Ref(:InstanceType)
    IamInstanceProfile Ref(:JenkinsInstanceProfile)
    NetworkInterfaces [
      {
        AssociatePublicIpAddress: true,
        DeleteOnTermination: true,
        SubnetId: Ref(:SubnetId),
        DeviceIndex: 0,
        GroupSet: [Ref(:SecurityGroup)]
      }
    ]
    Tags [
      {
        Key: 'Name',
        Value: FnJoin(' - ', [
                        'AWS DevSecOps Workshop Jenkins',
                        ENV['USER'].upcase
                      ])
      }
    ]

    wait_handle = [
      "#!/bin/bash\n",
      'export wait_handle="', Ref(:WaitHandle), "\"\n",
      'export vpc_id="', Ref(:VPCID), "\"\n",
      'export subnet_id="', Ref(:SubnetId), "\"\n",
      'export world_cidr="', Ref(:WorldCIDR), "\"\n"
    ]

    script_path = 'provisioning/cloudformation/jenkins-userdata.sh'
    script_data = File.read(script_path).split("\n").map { |line| line + "\n" }

    UserData FnBase64(FnJoin('', wait_handle + script_data))
  end

  IAM_Role(:JenkinsRole) do
    AssumeRolePolicyDocument(
      Statement: [{
        Effect: 'Allow',
        Principal: {
          Service: [
            'ec2.amazonaws.com'
          ]
        },
        Action: [
          'sts:AssumeRole'
        ]
      }]
    )

    Path '/'

    Policies [{
      PolicyName: 'aws-devsecops-jenkins-role',
      PolicyDocument: {
        Statement: [
          {
            Effect: 'Allow',
            Action: 'cloudformation:*',
            Resource: '*'
          },
          {
            Effect: 'Allow',
            Action: 'ec2:*',
            Resource: '*'
          }
        ]
      }
    }]
  end

  IAM_InstanceProfile(:JenkinsInstanceProfile) do
    Path '/'
    Roles [Ref(:JenkinsRole)]
  end

  Output(:JenkinsIP, FnGetAtt(:JenkinsServer, 'PublicIp'))
end
