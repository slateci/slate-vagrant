#!/bin/bash

set -e
set -o pipefail
export  KUBECONFIG='/etc/kubernetes/admin.conf'
ready="false"
template='{{range .items}}{{range .status.conditions}}{{if eq (.type) ("Ready")}}{{.status}}{{end}}{{end}}{{end}}'
while [ "$ready" != 'True' ]; do
  echo "[$(date)][INFO] Waiting for Kubernetes to become ready."
  sleep 5
  ready="$(kubectl get nodes -l node-role.kubernetes.io/master= -o go-template="$template" 2>/dev/null)" || true
done
echo "[$(date)][INFO] Kube Ready!"