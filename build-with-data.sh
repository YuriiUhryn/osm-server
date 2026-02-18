#!/bin/bash
# Bash script to build OSM tile server image with pre-imported data

set -e

IMAGE_NAME="${1:-osm-tile-server:latest}"
ENV_FILE="${2:-.env}"

echo "=========================================="
echo "Building OSM Tile Server with Data"
echo "=========================================="

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: $ENV_FILE not found!"
    echo "Please create a .env file with your configuration."
    exit 1
fi

# Load environment variables from .env
export $(grep -v '^#' "$ENV_FILE" | xargs)

if [ -z "$DOWNLOAD_PBF" ]; then
    echo "ERROR: DOWNLOAD_PBF not set in $ENV_FILE"
    exit 1
fi

THREADS="${THREADS:-4}"

echo ""
echo "Configuration:"
echo "  Image: $IMAGE_NAME"
echo "  PBF: $DOWNLOAD_PBF"
echo "  Threads: $THREADS"
echo ""

# Step 1: Build base image
echo "Step 1: Building base image..."
docker-compose build

# Step 2: Run import in temporary container
echo ""
echo "Step 2: Running data import (this may take a while)..."
TEMP_CONTAINER="osm-import-temp-$$"

docker run --name "$TEMP_CONTAINER" \
    -e DOWNLOAD_PBF="$DOWNLOAD_PBF" \
    -e DOWNLOAD_POLY="$DOWNLOAD_POLY" \
    -e THREADS="$THREADS" \
    "$IMAGE_NAME" import

# Step 3: Commit container to new image
echo ""
echo "Step 3: Creating final image with data..."
docker commit \
    --change='CMD ["run"]' \
    --change='ENV DOWNLOAD_PBF=' \
    --change='ENV DOWNLOAD_POLY=' \
    "$TEMP_CONTAINER" "$IMAGE_NAME"

# Step 4: Cleanup
echo ""
echo "Step 4: Cleaning up..."
docker rm "$TEMP_CONTAINER"

# Get image size
IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "{{.Size}}")

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="
echo "Image: $IMAGE_NAME"
echo "Size: $IMAGE_SIZE"
echo ""
echo "To run the server:"
echo "  docker-compose up -d"
echo ""
echo "To share this image:"
echo "  docker save $IMAGE_NAME | gzip > osm-tile-server.tar.gz"
echo "=========================================="
