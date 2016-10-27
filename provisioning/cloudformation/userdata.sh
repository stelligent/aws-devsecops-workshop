#!/bin/bash
set -e

# Grab security updates
yum update -y

# Configure working directories
mkdir -p /opt/nginx /opt/awsagent

# Install AWS Agent (Inspector)
pushd /opt/awsagent
  wget https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
  curl -O https://d1wk0tztpsntt1.cloudfront.net/linux/latest/install
  bash install -u false
  /etc/init.d/awsagent start
popd

# Install nginx dependencies
yum install -y pcre-devel zlib-devel openssl-devel
yum install -y gcc make

# Download nginx
pushd /opt/nginx
  wget http://nginx.org/download/nginx-1.11.5.tar.gz
  tar xzf nginx-1.11.5.tar.gz
popd

# Install nginx
pushd /opt/nginx/nginx-1.11.5
  ./configure --sbin-path=/usr/local/sbin --with-http_ssl_module
  make
  make install
popd

# Start nginx
/usr/local/sbin/nginx

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
