#!/bin/bash

set -e
set -o pipefail
sed -i "s|__HOST_IP__|${VAGRANT_HOST_IP}|g" "${FILES_DEST_DIR}/kubeadm.yaml"
