#!/bin/bash

set -e
set -o pipefail

CNI_VERSION="v0.6.0"
K8S_RELEASE="v1.10.1"
CFSSL_RELEASE="R1.2"
CRI_TOOLS_RELEASE="v1.0.0-beta.0"

echo "Fetching..."
echo "CNI_VERSION: $CNI_VERSION"
echo "K8S_RELEASE: $K8S_RELEASE"
echo "CFSSL_RELEASE: $CFSSL_RELEASE"
echo "CRI_TOOLS_RELEASE: $CRI_TOOLS_RELEASE"

wget -qO - "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
wget -qO - "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRI_TOOLS_RELEASE}/crictl-${CRI_TOOLS_RELEASE}-linux-amd64.tar.gz" | tar -C /opt/bin -xz
wget -qNP /opt/bin https://storage.googleapis.com/kubernetes-release/release/${K8S_RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
wget -qN "https://pkg.cfssl.org/${CFSSL_RELEASE}/cfssl_linux-amd64" -O /opt/bin/cfssl
wget -qN "https://pkg.cfssl.org/${CFSSL_RELEASE}/cfssljson_linux-amd64" -O /opt/bin/cfssljson
chmod +x /opt/bin/{cfssl,cfssljson,crictl,kubeadm,kubelet,kubectl}
