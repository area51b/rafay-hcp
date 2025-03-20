#!/bin/bash
set -e

echo "Starting HCP cluster initialization..."

# Set a writable KUBECONFIG path
export KUBECONFIG=/tmp/kubeconfig
touch /tmp/kubeconfig
chmod 666 /tmp/kubeconfig

echo "Downloading and extracting oc CLI..."
curl -k -L -o /tmp/oc.tar "$OC_CLI_URL"  # Ignore SSL verification
tar -xvf /tmp/oc.tar -C /tmp/
chmod +x /tmp/oc

echo "Downloading and extracting hcp CLI..."
curl -k -L -o /tmp/hcp.tar.gz "$HCP_URL"  # Ignore SSL verification
tar -xvf /tmp/hcp.tar.gz -C /tmp/
chmod +x /tmp/hcp

# Add /tmp to PATH so oc and hcp can be used without full path
export PATH="/tmp:$PATH"

echo "Logging into OpenShift..."
oc login --server="$OC_LOGIN_URL" --username="$OC_USERNAME" --password="$OC_PASSWORD" --insecure-skip-tls-verify=true

echo "Running hcp create cluster command..."
hcp create cluster kubevirt \
  --name "$CLUSTER_NAME" \
  --release-image "$RELEASE_IMAGE" \
  --node-pool-replicas "$NODE_POOL_REPLICAS" \
  --pull-secret /tmp/pull-secret.json \
  --memory "$MEMORY" \
  --cores "$CORES" \
  --etcd-storage-class "$ETCD_STORAGE_CLASS"

# Wait and verify cluster creation
echo "Waiting for cluster to be ready..."
/usr/local/bin/hcp-cluster-check.sh "$CLUSTER_NAME"

echo "HCP cluster creation completed successfully!"
exit 0
