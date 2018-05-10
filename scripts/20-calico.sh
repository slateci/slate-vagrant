#!/bin/bash

set -e
set -o pipefail

echo "Starting Calico"
kubectl create -f /opt/files/calico-rbac.yaml
kubectl create -f /opt/files/calico.yaml
