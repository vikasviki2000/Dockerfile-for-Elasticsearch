# Use a base Ubuntu image
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    openjdk-11-jre-headless \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add the Elasticsearch GPG key and repository
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add - \
    && echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list \
    && apt-get update

# Install Elasticsearch
RUN apt-get install -y elasticsearch

# Set environment variables for Elasticsearch
ENV PATH=$PATH:/usr/share/elasticsearch/bin

# Set up Elasticsearch user and directories
RUN getent group elasticsearch || groupadd -g 1000 elasticsearch && \
    getent passwd elasticsearch || useradd -u 1000 -g 1000 elasticsearch && \
    mkdir -p /usr/share/elasticsearch/data /usr/share/elasticsearch/logs && \
    chown -R elasticsearch:elasticsearch /usr/share/elasticsearch

# Copy configuration files (elasticsearch.yml, logging.yml)
COPY elasticsearch.yml /usr/share/elasticsearch/config/
# Uncomment the line below if you have the logging.yml file
# COPY logging.yml /usr/share/elasticsearch/config/

# Switch to elasticsearch user
USER elasticsearch

# Expose Elasticsearch ports
EXPOSE 9200 9300

# Set the command to start Elasticsearch
CMD ["elasticsearch"]

