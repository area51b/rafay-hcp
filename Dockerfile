FROM debian:latest

# Install required dependencies
RUN apt-get update && apt-get install -y curl tar bash jq && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp

# Copy initialization scripts
COPY hcp-init.sh /usr/local/bin/hcp-init.sh
COPY hcp-cluster-check.sh /usr/local/bin/hcp-cluster-check.sh

# Set executable permissions
RUN chmod +x /usr/local/bin/hcp-init.sh /usr/local/bin/hcp-cluster-check.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/hcp-init.sh"]
