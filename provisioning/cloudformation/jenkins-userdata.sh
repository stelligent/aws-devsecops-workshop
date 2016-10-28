#!/bin/bash
set -ex

# Install ZAP - Penetration Test
mkdir -p /opt/ZAP
pushd /opt/ZAP
  wget https://github.com/zaproxy/zaproxy/releases/download/2.5.0/ZAP_2.5.0_Linux.tar.gz
  tar xf ZAP_2.5.0_Linux.tar.gz
  pushd ZAP_2.5.0
    nohup ./zap.sh -daemon -port 80 -config api.disablekey=true &
  popd
popd

# Install apache benchmark - Easy Capacity Testing
apt-get install -y apache2-utils

# Update Jenkins with some build parameters
sed -i.bak "s#VPCID_TOKEN#${vpc_id}#g" /var/lib/jenkins/config.xml
sed -i.bak "s#SUBNETID_TOKEN#${subnet_id}#g" /var/lib/jenkins/config.xml
sed -i.bak "s#0.0.0.0/0#${world_cidr}#g" /var/lib/jenkins/config.xml

# Restart Jenkins
service jenkins restart
sleep 30s

# Create the CloudFormation wait handle JSON
cat > /tmp/cfn-success <<CFNSUCCESS
{
   "Status" : "SUCCESS",
   "Reason" : "Configuration Complete",
   "UniqueId" : "$(uuidgen)",
   "Data" : "Application has completed configuration."
}
CFNSUCCESS

# Emit success to CloudFormation
curl -T /tmp/cfn-success "${wait_handle}"
