#!/usr/bin/env bash

echo "##### Cluster Initialization #####"
## check if the lifecycle cluster is in kind
kind_clusters=$(kind get clusters)
lifecycle_cluster="lifecycle-local"
cluster_found=1

for cluster in $kind_clusters; do
  if [[ "$cluster" == "${lifecycle_cluster}" ]]; then
    cluster_found=0
  fi
done

if [[ "${cluster_found}" == 1 ]]; then
  echo "create the kind cluster"
  kind create cluster --name "${lifecycle_cluster}" --config cluster.yml
fi

## wait for the apiserver to be ready
attempts=0
while [ "$attempts" -lt 6 ]; do
  apiserver_status=$(kubectl -n kube-system get pod "kube-apiserver-${lifecycle_cluster}-control-plane" -o jsonpath="{.status.phase}")
  echo "waiting on apiserver, current status: ${apiserver_status}"
  if [[ "${apiserver_status}" == "Running" ]]; then
    break
  fi
  if [ "$attempts" -eq 5 ]; then
    echo "apiserver did not come up in time"
    exit 1
  fi
  attempts=$[$attempts+1]
  sleep 10
done

echo -e "\n##### Application Configuraiton #####"
## load the required docker image into the kind cluster
kind load docker-image --name "${lifecycle_cluster}" cratekube/lifecycle-service:local
kind load docker-image --name "${lifecycle_cluster}" cratekube/lifecycle-service:1.0.0
kind load docker-image --name "${lifecycle_cluster}" cratekube/cloud-mgmt-service:1.0.0
kind load docker-image --name "${lifecycle_cluster}" cratekube/cluster-mgmt-service:1.0.0

## apply the database and application deployment
echo "applying the application deployment"
kubectl apply -f deployment.yml

sleep 10

## output internal kubeconfig
kind get kubeconfig --name "${lifecycle_cluster}" --internal > ./test/kubeconfig

## output the url the service is running on
hostIP=$(kubectl get pod -l name=lifecycle-service -o jsonpath="{.items[0].status.hostIP}")
nodePort=$(kubectl get svc lifecycle-service -o jsonpath="{.spec.ports[0].nodePort}")
echo -e "\nlifecycle-service can be accessed at http://${hostIP}:${nodePort}"
