#!/bin/bash

set -e
set -o pipefail

echo "Installing Prerequisites."
tar -xvzf /opt/downloads/cni-plugins.tgz -C /opt/cni/bin
tar -xvzf /opt/downloads/crictl.tgz -C /opt/bin

echo "Initializing Kubernetes."
kubeadm init --config=/opt/config/kubeadm.yaml

mkdir -p "$HOME/.kube"
cp /etc/kubernetes/admin.conf "$HOME/.kube/config"

mkdir -p /home/core/.kube
cp /etc/kubernetes/admin.conf /home/core/.kube/config
chown core:core /home/core/.kube/config
# hack but it works
# for single mode
kubectl taint nodes --all node-role.kubernetes.io/master-

# deploy calico
kubectl create -f /opt/config/calico-rbac.yaml
kubectl create -f /opt/config/calico.yaml

# deploy metallb
kubectl create -f /opt/config/metallb.yaml