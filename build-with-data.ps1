#!/usr/bin/env pwsh
# PowerShell script to build OSM tile server image with pre-imported data

param(
    [string]$ImageName = "osm-tile-server:latest",
    [string]$EnvFile = ".env"
)

Write-Host "=========================================="
Write-Host "Building OSM Tile Server with Data"
Write-Host "=========================================="

# Check if .env file exists
if (-not (Test-Path $EnvFile)) {
    Write-Host "ERROR: $EnvFile not found!" -ForegroundColor Red
    Write-Host "Please create a .env file with your configuration."
    exit 1
}

# Load environment variables from .env
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.+)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        Set-Item -Path "env:$name" -Value $value
    }
}

$DOWNLOAD_PBF = $env:DOWNLOAD_PBF
$DOWNLOAD_POLY = $env:DOWNLOAD_POLY
$THREADS = if ($env:THREADS) { $env:THREADS } else { "4" }

if (-not $DOWNLOAD_PBF) {
    Write-Host "ERROR: DOWNLOAD_PBF not set in $EnvFile" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configuration:"
Write-Host "  Image: $ImageName"
Write-Host "  PBF: $DOWNLOAD_PBF"
Write-Host "  Threads: $THREADS"
Write-Host ""

# Step 1: Build base image
Write-Host "Step 1: Building base image..." -ForegroundColor Cyan
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to build base image" -ForegroundColor Red
    exit 1
}

# Step 2: Run import in temporary container
Write-Host ""
Write-Host "Step 2: Running data import (this may take a while)..." -ForegroundColor Cyan
$tempContainer = "osm-import-temp-$(Get-Random)"

docker run --name $tempContainer `
    -e DOWNLOAD_PBF=$DOWNLOAD_PBF `
    -e DOWNLOAD_POLY=$DOWNLOAD_POLY `
    -e THREADS=$THREADS `
    $ImageName import

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Import failed" -ForegroundColor Red
    docker rm $tempContainer 2>$null
    exit 1
}

# Step 3: Commit container to new image
Write-Host ""
Write-Host "Step 3: Creating final image with data..." -ForegroundColor Cyan
docker commit `
    --change='CMD ["run"]' `
    --change='ENV DOWNLOAD_PBF=' `
    --change='ENV DOWNLOAD_POLY=' `
    $tempContainer $ImageName

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to commit image" -ForegroundColor Red
    docker rm $tempContainer 2>$null
    exit 1
}

# Step 4: Cleanup
Write-Host ""
Write-Host "Step 4: Cleaning up..." -ForegroundColor Cyan
docker rm $tempContainer

# Get image size
$imageInfo = docker images $ImageName --format "{{.Size}}"

Write-Host ""
Write-Host "=========================================="
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "=========================================="
Write-Host "Image: $ImageName"
Write-Host "Size: $imageInfo"
Write-Host ""
Write-Host "To run the server:"
Write-Host "  docker-compose up -d"
Write-Host ""
Write-Host "To share this image:"
Write-Host "  docker save $ImageName | gzip > osm-tile-server.tar.gz"
Write-Host "=========================================="
