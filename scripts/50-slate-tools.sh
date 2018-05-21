#!/bin/bash
# Change to slate-ci/slate-tools after merge
wget -q https://raw.githubusercontent.com/benkulbertis/slate-tools/master/slate-tools-container/Dockerfile
docker build . -t slate-tools
docker run -it -d --name slate-tools -v $HOME/.kube/config:/usr/lib/slate-service/etc/kubeconfig slate-tools
docker exec slate-tools kubectl create -f https://raw.githubusercontent.com/Azure/helm-charts/master/docs/prerequisities/helm-rbac-config.yaml
docker exec slate-tools helm init --service-account tiller
