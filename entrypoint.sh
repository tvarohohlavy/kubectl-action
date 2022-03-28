#!/bin/sh

set -e

# Extract the base64 encoded config data and write this to the KUBECONFIG
mkdir -p ~/.kube
echo $INPUT_KUBECONFIG | base64 -d > ~/.kube/config

# Execute multiple kubectl commands
echo "$*" | while IFS= read line ; do kubectl $line; done
