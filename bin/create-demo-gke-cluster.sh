#!/bin/bash

# Author: Bharath Raj
# This script is collection of kubectl and gcp commands to do the following - 
# 1. Create GKE compute cluster
# 2. Create app namespace
# 3. Create app config map
# 4. Create app secrets
# 5. Create istio egress rules
# 6. Create app deployment
# 7. Create app service for exposure
# 8. Create istio ingress gateway
# 9. Monitor the app service
# 10. Test app service

# The other objective of this script is to see how quickly 
# we can create a GKE cluster and many such apps from scratch
# and also expose the service
# measuring a time to failover to GCP

# This script needs to be run with appropriate IAM role that has
# privileges for provisioning all the resources

HOME=$(dirname $0)
DEPLOYMENT_CONF_PATH=${HOME}/../deployments
CLUSTER_NAME=${1:-crud-app-demo-cluster-1}

# 1. Create GKE compute cluster
gcloud beta container --project "hip-microservices-experiment-2" clusters create "${CLUSTER_NAME}" --region "australia-southeast1" --username "admin" --cluster-version "1.11.6-gke.11" --machine-type "n1-standard-4" --image-type "COS" --disk-type "pd-standard" --disk-size "50" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "2" --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias --network "projects/hip-microservices-experiment-2/global/networks/default" --subnetwork "projects/hip-microservices-experiment-2/regions/australia-southeast1/subnetworks/default" --default-max-pods-per-node "110" --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard,Istio --istio-config auth=MTLS_PERMISSIVE --enable-autoupgrade --enable-autorepair 

# Authenticate to cluster
# gcloud container clusters get-credentials ${CLUSTER_NAME} --region australia-southeast1

# 2. Create app namespace
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/namespace.yaml

# 3. Create app configmap
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/app/app-configmap.yaml

# 4. Create app secrets
if [[ -z ${POSTGRES_USERNAME} || -z ${POSTGRES_PASSWORD} ]]; then
  echo "No secrets set. Skipping"
else
  kubectl create secret generic postgres-creds --from-literal postgres-password=${POSTGRES_PASSWORD} --from-literal postgres-username=${POSTGRES_USERNAME} -n dev
fi

# 5. Create istio egress rules
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/istio/postgres-egress-entry.yaml

# 6. Deploy app v1
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/app/app-deployment.yaml

# 7. Create app service
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/app/app-service.yaml

# 8. Create istio ingress gateway
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/istio/ingress-gw.yaml

# 9. Monitoring - SignalFX

kubectl create secret generic --from-literal access-token=${SIGNALFX_ACCESS_TOKEN} signalfx-agent

cat ${DEPLOYMENT_CONF_PATH}/signalfx/signalfx-smart-agent/*.yaml | kubectl apply -f -
cat ${DEPLOYMENT_CONF_PATH}/signalfx/signalfx-istio-adapter/*.yaml | sed -e "s/MY_ACCESS_TOKEN/${SIGNALFX_ISTIO_ACCESS_TOKEN}/" | kubectl apply -f -

# 10. Test app v1
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

while [ $(curl -I -s http://${INGRESS_HOST}/api | head -n1 | awk '{print $2}') -ne 200 ]; do
  echo "App isn't responsive yet. Retrying..."
  sleep 1
done

# 11. Deploy app v2
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/app/app-deployment-v2.yaml

# 12. Deploy istio canary config
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/istio/ingress-gw-canary.yaml
kubectl apply -f ${DEPLOYMENT_CONF_PATH}/istio/ingress-destination-rule.yaml

13.Test app in canary mode
while [ $(curl -I -s http://${INGRESS_HOST}/api | head -n1 | awk '{print $2}') -ne 200 ]; do
  echo "App isn't responsive yet. Retrying..."
  sleep 1
done

