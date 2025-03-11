#!/bin/bash
set -e

echo "Logging into OpenShift..."
oc login --server="$OC_LOGIN_URL" --username="$OC_USERNAME" --password="$OC_PASSWORD" --insecure-skip-tls-verify=true

echo "Creating HCP cluster..."
hcp create cluster kubevirt \
  --name "$CLUSTER_NAME" \
  --release-image "$RELEASE_IMAGE" \
  --node-pool-replicas "$NODE_POOL_REPLICAS" \
  --pull-secret /pull-secret.json \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --etcd-storage-class "$ETCD_STORAGE_CLASS"

echo "HCP cluster creation completed successfully!"
