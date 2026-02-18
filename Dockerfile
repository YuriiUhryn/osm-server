# OpenStreetMap Tile Server - Custom Build
FROM overv/openstreetmap-tile-server:latest

# Install additional utilities
RUN apt-get update && \
    apt-get install -y curl postgresql-client && \
    rm -rf /var/lib/apt/lists/*


# Expose port 80 for tile server
EXPOSE 80

# Use the default entrypoint from base image
CMD ["run"]
