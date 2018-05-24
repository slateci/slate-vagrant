#!/bin/bash

slate-tools () {
  docker exec slate-tools "$@"
}

# Set up container
wget -q https://raw.githubusercontent.com/slateci/slate-tools/master/slate-tools-container/Dockerfile
docker build . -t slate-tools
rm Dockerfile
bashrc="/home/core/.bashrc"
docker run -it -d --name slate-tools -v $HOME/.kube/config:/usr/lib/slate-service/etc/kubeconfig slate-tools
rm $bashrc && cp /usr/share/skel/.bashrc $bashrc
echo "alias slate-tools='docker exec slate-tools'" >> $bashrc
# Helm
slate-tools kubectl create -f https://raw.githubusercontent.com/Azure/helm-charts/master/docs/prerequisities/helm-rbac-config.yaml
slate-tools helm init --service-account tiller
slate-tools kubectl rollout status -w deployment/tiller-deploy --namespace=kube-system
# Nginx
slate-tools kubectl create deployment nginx --image=nginx
slate-tools kubectl expose deployment nginx --type=LoadBalancer --name=nginx-svc --port 80
# Slate Catalog
slate-tools helm repo add slate-dev https://raw.githubusercontent.com/slateci/slate-catalog/master/incubator-repo/
slate-tools helm repo add slate https://raw.githubusercontent.com/slateci/slate-catalog/master/stable-repo/
# Frontier Squid
slate-tools helm install slate-dev/osg-frontier-squid
slate-tools kubectl expose deployment osg-frontier-squid-deployment --port=3128 --type=LoadBalancer --name=squid-svc
# Elasticsearch
#slate-tools helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
#slate-tools helm install incubator/elasticsearch
# perfSONAR
slate-tools kubectl create -f https://raw.githubusercontent.com/slateci/slate-deployment/master/perfsonar/perfsonar.yaml
# Dashboard
slate-tools kubectl apply -f https://raw.githubusercontent.com/slateci/slate-vagrant/slate-tools-docker/files/kubernetes-dashboard.yaml
slate-tools kubectl expose deployment kubernetes-dashboard --port=443 --target-port=8443 --type=LoadBalancer --name=dashboard-svc
