#!/bin/bash
set -e

# Grab security updates
yum update -y

# Install nginx dependencies
yum install -y pcre-devel zlib-devel openssl-devel
yum install -y gcc make

# Configure working directory
mkdir -p /opt/nginx

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
