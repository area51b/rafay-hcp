#!/bin/bash
set -e

# Input parameters
CLUSTER_NAME="$1"
NAMESPACE="clusters"  # Namespace where the cluster is created
TIMEOUT_MINUTES=60  # Max timeout in minutes
INTERVAL_SECONDS=60  # Interval between status checks

# Function to check cluster availability
check_cluster_status() {
    echo "Checking HostedCluster status for '$CLUSTER_NAME'..."
    
    for ((i=0; i<TIMEOUT_MINUTES; i++)); do
        echo "Running: oc get --namespace $NAMESPACE hostedclusters $CLUSTER_NAME -o json"
        STATUS_JSON=$(oc get --namespace $NAMESPACE hostedclusters $CLUSTER_NAME -o json 2>/dev/null || echo "{}")
        # Print the output to debug
        echo "STATUS_JSON: $STATUS_JSON"

        STATUS_TYPE=$(echo "$STATUS_JSON" | jq -r '.status.conditions[] | select(.type=="Available") | .status' 2>/dev/null)
        echo "Status: $STATUS_TYPE"

        if [[ "$STATUS_TYPE" == "True" ]]; then
            echo "Cluster '$CLUSTER_NAME' is available."
            return 0
        fi

        echo "Cluster is not available yet. Retrying in $INTERVAL_SECONDS seconds..."
        sleep $INTERVAL_SECONDS
    done

    echo "Timeout reached! Cluster '$CLUSTER_NAME' is not available after $TIMEOUT_MINUTES minutes."
    exit 1
}

# Function to download kubeconfig
download_kubeconfig() {
    echo "Downloading kubeconfig..."
    if hcp create kubeconfig --name "$CLUSTER_NAME" > kubeconfig; then
        echo "Kubeconfig downloaded successfully."
    else
        echo "Failed to download kubeconfig!"
        exit 1
    fi
}

# Function to check node readiness
check_node_status() {
    echo "Checking node readiness..."

    for ((i=0; i<TIMEOUT_MINUTES; i++)); do
        NODES_JSON=$(oc get node --kubeconfig=kubeconfig -o json 2>/dev/null || echo "{}")
        NOT_READY_NODES=$(echo "$NODES_JSON" | jq '[.items[] | select(.status.conditions[] | select(.type=="Ready" and .status!="True"))] | length')

        if [[ "$NOT_READY_NODES" == "0" ]]; then
            echo "All nodes are in Ready state."
            return 0
        fi

        echo "Some nodes are not Ready yet. Retrying in $INTERVAL_SECONDS seconds..."
        sleep $INTERVAL_SECONDS
    done

    echo "Timeout reached! Some nodes are still not Ready after $TIMEOUT_MINUTES minutes."
    exit 1
}

### **Main Execution Flow**
check_cluster_status
download_kubeconfig
check_node_status

echo "Cluster '$CLUSTER_NAME' is fully available with all nodes Ready!"
exit 0
