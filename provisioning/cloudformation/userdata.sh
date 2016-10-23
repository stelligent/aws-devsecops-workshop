#!/bin/bash
set -e

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
