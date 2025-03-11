# Use a lightweight base image
FROM alpine:latest

# Install required dependencies
RUN apk add --no-cache curl tar bash jq

# Set working directory
WORKDIR /app

# Download and extract the OpenShift CLI (oc)
ARG OC_CLI_URL
RUN curl -L ${OC_CLI_URL} -o oc.tar && \
    tar -xvf oc.tar && \
    chmod +x oc && \
    mv oc /usr/local/bin/

# Download and extract the HCP CLI
ARG HCP_URL
RUN curl -L ${HCP_URL} -o hcp.tar.gz && \
    tar -xvf hcp.tar.gz && \
    chmod +x hcp && \
    mv hcp /usr/local/bin/

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Define entrypoint
ENTRYPOINT ["/entrypoint.sh"]
