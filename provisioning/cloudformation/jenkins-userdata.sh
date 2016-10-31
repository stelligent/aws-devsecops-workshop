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

# Install nodejs for config-rules-status
curl -sL https://deb.nodesource.com/setup_6.x | bash -
apt-get install -y nodejs
npm install --global serverless@0.5.5
npm install --global gulp-cli
pip install awscli

# Install config-rules-status
# Go-go gadget Rube Goldberg machine
pushd /opt
  git clone https://github.com/stelligent/config-rule-status.git
  pushd config-rule-status
    # No tags
    git reset --hard "90e7cb0c6907b05f1a14c2a5093a38dde3f1be2e"

    # Requires api access keys :ultimate-sadness:
    aws configure set default.region "${region}"
    aws iam create-access-key \
      --region "${region}" \
      --user-name "${config_rules_user}" \
      --output json > config_rules_user.json
    aws configure set aws_access_key_id \
      $(cat config_rules_user.json | jq '.AccessKey.AccessKeyId' -r)
    aws configure set aws_secret_access_key \
      $(cat config_rules_user.json | jq '.AccessKey.SecretAccessKey' -r)
    rm -f config_rules_user.json

    # Install / run the config-rules-status
    npm install
    gulp init \
      --region "${region}" \
      --stage prod \
      --name AWS-DEVSECOPS-WORKSHOP \
      --awsProfile default \
      --email no-reply@stelligent.com
    gulp build
    gulp deploy:lambda --stage prod --region "${region}"
    gulp deploy:config --stage prod --region "${region}"
  popd
  chmod -R jenkins:jenkins config-rule-status
popd


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
