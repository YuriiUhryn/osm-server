# OpenStreetMap Tile Server

All-in-one Docker setup for running an OpenStreetMap tile server with automatic data import and custom styles.

## Features

- **🚀 Pre-Built Images**: Build script creates images with all data pre-imported
- **⚡ Instant Start**: Pre-built images run immediately without setup time
- **📦 Easy Sharing**: Build once, share anywhere (Docker Hub, GHCR, or tar file)
- **🎨 Custom Styles**: Support for custom map styles (place files in `./style/` directory)
- **⚙️ Environment-based Configuration**: All settings configured via `.env` file
- **🔄 Automatic Updates**: Optional automatic tile updates from OSM
- **🌍 CORS Enabled**: Cross-origin resource sharing enabled by default
- **💾 Tile Cache**: Optional volume for rendered tile persistence

## Quick Start

### Prerequisites

- Docker installed and running
- Docker Compose installed
- At least 4GB RAM available
- Sufficient disk space (Luxembourg: ~5GB, larger regions require more)

## Build Pre-Imported Image (Recommended for Sharing)

### Method 1: Using Build Script

This creates a complete image with all OSM data that can be shared easily.

#### Step 1: Configure Region

The `.env` file is pre-configured with Netherlands. Edit to change region:

```bash
# Edit .env to change region or settings
# Default configuration:
# - Region: Netherlands
# - Port: 8080

# Available regions: https://download.geofabrik.de/
```

#### Step 2: Build Image with Data Import

**On Windows (PowerShell):**

```powershell
.\build-with-data.ps1
```

**On Linux/Mac:**

```bash
chmod +x build-with-data.sh
./build-with-data.sh
```

This script will:

1. Build the base Docker image
2. Run a container to import OSM data
3. Commit the container to create final image with all data

**Import time**:

- Luxembourg: ~5-10 minutes
- Netherlands: ~30-60 minutes
- Larger regions take longer

#### Step 3: Run the Server

```bash
# Start the server (runs instantly!)
docker-compose up -d
```

The server starts immediately with all data ready!

#### Step 4: Access Your Tile Server

- **Tiles API**: http://localhost:8080/tile/{z}/{x}/{y}.png
- **Demo Map**: http://localhost:8080/
- **MapLibre Demo**: http://localhost:8080/maplibre-demo.html

---

### Method 2: Simple Build (Import on First Run)

For quick testing without creating a pre-built image:

```bash
# Build base image
docker-compose build

# Start (imports data on first run)
docker-compose up -d

# Monitor import progress
docker-compose logs -f
```

**First run import time**: Same as Method 1 (Luxembourg ~5-10 mins, Netherlands ~30-60 mins)

---

## Sharing the Image

The built image contains all OSM data and is ready to run immediately on any machine.

See [BUILD.md](BUILD.md) for detailed instructions on:

- Building and pushing to Docker Hub or GitHub Container Registry
- Saving/loading images as tar files
- Image size considerations
- Building for different regions

Quick example:

```bash
# Save to file for sharing (will be large: 3GB-50GB depending on region)
docker save osm-tile-server:latest | gzip > osm-tile-server.tar.gz

# Load on another machine
docker load < osm-tile-server.tar.gz

# Run immediately - no configuration needed!
docker run -d -p 8080:80 -v osm-tiles:/data/tiles/ osm-tile-server:latest
```

The recipient can start using the tile server instantly with no download or import time.

---

## Alternative: Docker Compose (Legacy Method with Profiles)

> **Note**: This section describes the original two-step profile-based approach using the base image. The recommended method above builds everything into a single image during the build phase.

If you prefer the two-step import/run approach:

### Method 2: Using Docker Compose Profiles

#### Step 1: Configure Environment

The `.env` file is pre-configured with Luxembourg (small test region) and dark theme. Edit if needed:

```bash
# Edit .env to change region or settings
# Default configuration:
# - Region: Luxembourg
# - Theme: Dark
# - Port: 8080
```

#### Step 2: Build and Import Data

```bash
# Import OSM data (downloads and processes data)
docker-compose --profile import up
```

This will:

- Pull the Docker image `overv/openstreetmap-tile-server`
- Create volumes `osm-data` and `osm-tiles`
- Download PBF file from `.env` (`DOWNLOAD_PBF`)
- Import data into PostgreSQL
- Apply dark theme styles
- Exit when complete (wait for "Import complete" message)

**Time**: Luxembourg ~10-30 minutes, Belgium ~1-2 hours, Germany ~6-12 hours

#### Step 3: Start the Tile Server

```bash
# Start the server in detached mode
docker-compose --profile run up -d
```

#### Step 4: Access Your Tile Server

- **Tiles API**: http://localhost:8080/tile/{z}/{x}/{y}.png
- **Demo Map**: http://localhost:8080/
- **MapLibre Demo**: http://localhost:8080/maplibre-demo.html

**Done!** Your tile server is now running with dark theme tiles.

---

### Method 2: Using Docker Commands Directly

For more control, use Docker commands directly without Docker Compose.

#### Step 1: Create Volumes

```bash
docker volume create osm-data
docker volume create osm-tiles
```

#### Step 2: Import Data

```bash
docker run --rm \
  --env-file .env \
  -v osm-data:/data/database/ \
  -v osm-tiles:/data/tiles/ \
  -v ./style:/data/style/ \
  overv/openstreetmap-tile-server \
  import
```

Or with explicit environment variables:

```bash
docker run --rm \
  -e DOWNLOAD_PBF=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf \
  -e DOWNLOAD_POLY=https://download.geofabrik.de/europe/luxembourg.poly \
  -e NAME_LUA=dark-theme.lua \
  -e NAME_STYLE=dark-theme.style \
  -e NAME_MML=dark-theme.mml \
  -e NAME_SQL=dark-theme.sql \
  -e THREADS=4 \
  -v osm-data:/data/database/ \
  -v osm-tiles:/data/tiles/ \
  -v ./style:/data/style/ \
  overv/openstreetmap-tile-server \
  import
```

#### Step 3: Run the Server

```bash
docker run -d \
  --name osm-tile-server \
  --env-file .env \
  -p 8080:80 \
  -v osm-data:/data/database/ \
  -v osm-tiles:/data/tiles/ \
  -v ./style:/data/style/ \
  overv/openstreetmap-tile-server \
  run
```

Or with explicit environment variables:

```bash
docker run -d \
  --name osm-tile-server \
  -e ALLOW_CORS=enabled \
  -e THREADS=4 \
  -e AUTOVACUUM=on \
  -e PGPASSWORD=renderer \
  -p 8080:80 \
  -v osm-data:/data/database/ \
  -v osm-tiles:/data/tiles/ \
  -v ./style:/data/style/ \
  overv/openstreetmap-tile-server \
  run
```

#### Step 4: Verify Server is Running

```bash
# Check container status
docker ps

# View logs
docker logs -f osm-tile-server
```

#### Access Your Tile Server

Same URLs as Method 1:

- **Tiles API**: http://localhost:8080/tile/{z}/{x}/{y}.png
- **Demo Map**: http://localhost:8080/
- **MapLibre Demo**: http://localhost:8080/maplibre-demo.html

## Common Operations

### Stop the Server

**Method 1 (Docker Compose):**

```bash
docker-compose --profile run down
```

**Method 2 (Docker):**

```bash
docker stop osm-tile-server
docker rm osm-tile-server
```

### View Logs

**Method 1 (Docker Compose):**

```bash
docker-compose --profile run logs -f
```

**Method 2 (Docker):**

```bash
docker logs -f osm-tile-server
```

### Restart Server

**Method 1 (Docker Compose):**

```bash
docker-compose --profile run restart
```

**Method 2 (Docker):**

```bash
docker restart osm-tile-server
```

### Re-import Different Region

1. Stop the server
2. Edit `.env` to change `DOWNLOAD_PBF` and `DOWNLOAD_POLY`
3. Clear old data:
   ```bash
   docker volume rm osm-data osm-tiles
   ```
4. Run import again (Method 1 or 2)
5. Start server again

### Clean Up Everything

**Warning: This deletes all imported data!**

```bash
# Stop containers
docker-compose --profile run down
# OR
docker stop osm-tile-server && docker rm osm-tile-server

# Remove volumes
docker volume rm osm-data osm-tiles
```

## Custom Styles

To use a custom map style:

1. Place your style files in the `./style/` directory:
   - `*.lua` - Lua transformation script
   - `*.style` - Style configuration
   - `*.mml` - CartoCSS project file
   - `*.sql` - SQL indexes

2. Update `.env` file with your style filenames:

   ```
   NAME_LUA=custom-style.lua
   NAME_STYLE=custom-style.style
   NAME_MML=custom-project.mml
   NAME_SQL=custom-indexes.sql
   ```

3. Run import and server with your custom style

**Example Dark Style**: The style directory can contain a dark theme similar to OpenFreeMap. Place your modified CartoCSS files there.

## Regions

Change the region by updating the `.env` file:

```bash
# Small regions (good for testing)
DOWNLOAD_PBF=https://download.geofabrik.de/europe/luxembourg-latest.osm.pbf
DOWNLOAD_POLY=https://download.geofabrik.de/europe/luxembourg.poly

# Medium regions
DOWNLOAD_PBF=https://download.geofabrik.de/europe/belgium-latest.osm.pbf
DOWNLOAD_POLY=https://download.geofabrik.de/europe/belgium.poly

# Large regions (requires more resources)
DOWNLOAD_PBF=https://download.geofabrik.de/europe/germany-latest.osm.pbf
DOWNLOAD_POLY=https://download.geofabrik.de/europe/germany.poly
```

Find more regions at [Geofabrik](https://download.geofabrik.de/).

## Automatic Updates

To enable automatic tile updates:

1. Set `UPDATES=enabled` in `.env`
2. Ensure `DOWNLOAD_POLY` is set (required for updates)
3. Re-run import and server

```bash
UPDATES=enabled
```

Updates will run periodically in the background, keeping your tiles up to date with OSM changes.

## Advanced Configuration

### Performance Tuning

Edit `.env`:

```bash
# Increase threads for faster import/rendering
THREADS=8

# PostgreSQL autovacuum
AUTOVACUUM=on
```

### Memory Issues

If import fails with memory errors, you may need to enable flat nodes mode. Add to the import command:

```bash
docker run \
    --env-file .env \
    -e "FLAT_NODES=enabled" \
    -v osm-data:/data/database/ \
    -v osm-tiles:/data/tiles/ \
    -v ./style:/data/style/ \
    overv/openstreetmap-tile-server \
    import
```

### Accessing PostgreSQL Database

Expose PostgreSQL port by editing `docker-compose.yml`:

```yaml
ports:
  - "${SERVER_PORT}:80"
  - "5432:5432" # Add this line
```

Connect:

```bash
psql -h localhost -U renderer -d gis
# Password: renderer (or value from PGPASSWORD in .env)
```

## Architecture

- **PostgreSQL**: Stores OSM data with PostGIS extension
- **Apache + mod_tile**: Serves tiles via HTTP
- **Mapnik**: Renders tiles from database
- **Renderd**: Tile rendering daemon

## File Structure

```
osm-server/
├── docker-compose.yml    # Docker Compose configuration
├── .env                  # Environment variables
├── style/                # Custom map styles (optional)
│   ├── *.lua
│   ├── *.style
│   ├── *.mml
│   └── *.sql
└── README.md            # This file
```

## Volumes

- **osm-data**: PostgreSQL database with OSM data
- **osm-tiles**: Cached rendered tiles

## Troubleshooting

### Import Process Exits Unexpectedly

Check available memory. Large imports require significant RAM. Consider:

- Using smaller regions
- Enabling `FLAT_NODES=enabled`
- Increasing Docker memory limits

### Tiles Not Rendering

1. Check logs: `docker-compose --profile run logs -f`
2. Verify import completed successfully
3. Ensure style files are present (or let it use default)
4. Wait for initial render (first tiles take time)

### Port Already in Use

Change `SERVER_PORT` in `.env`:

```bash
SERVER_PORT=9090
```

### Shared Memory Error

Add to `docker-compose.yml` under `osm-tile-server`:

```yaml
shm_size: "192m"
```

## Resources

- [OpenStreetMap Tile Server GitHub](https://github.com/Overv/openstreetmap-tile-server)
- [Geofabrik Downloads](https://download.geofabrik.de/)
- [OpenStreetMap Carto](https://github.com/gravitystorm/openstreetmap-carto)
- [Switch2OSM Guide](https://switch2osm.org/)

## License

This project uses the [overv/openstreetmap-tile-server](https://github.com/Overv/openstreetmap-tile-server) Docker image, licensed under Apache 2.0.

OpenStreetMap data is © OpenStreetMap contributors, available under the [Open Database License](https://www.openstreetmap.org/copyright).
