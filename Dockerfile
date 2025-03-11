FROM debian:latest

# Install required dependencies
RUN apt-get update && apt-get install -y curl tar bash jq && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp

# Copy startup script
COPY hcp-init.sh /usr/local/bin/hcp-init.sh
RUN chmod +x /usr/local/bin/hcp-init.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/hcp-init.sh"]
