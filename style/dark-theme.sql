-- Dark theme SQL indexes
-- Basic indexes for improved rendering performance

-- Indexes for water features
CREATE INDEX IF NOT EXISTS idx_water_polygon ON planet_osm_polygon USING GIST (way) WHERE "natural" IN ('water', 'bay') OR waterway IN ('riverbank', 'dock', 'canal') OR landuse IN ('reservoir', 'basin');

CREATE INDEX IF NOT EXISTS idx_waterway_line ON planet_osm_line USING GIST (way) WHERE waterway IN ('river', 'stream', 'canal', 'drain', 'ditch');

-- Indexes for landuse
CREATE INDEX IF NOT EXISTS idx_landuse_polygon ON planet_osm_polygon USING GIST (way) WHERE landuse IS NOT NULL OR "natural" IN ('wood', 'forest', 'grass') OR leisure = 'park';

-- Indexes for buildings
CREATE INDEX IF NOT EXISTS idx_buildings ON planet_osm_polygon USING GIST (way) WHERE building IS NOT NULL;

-- Indexes for roads
CREATE INDEX IF NOT EXISTS idx_roads ON planet_osm_line USING GIST (way) WHERE highway IS NOT NULL;

-- Indexes for railways
CREATE INDEX IF NOT EXISTS idx_railway ON planet_osm_line USING GIST (way) WHERE railway = 'rail';

-- Indexes for boundaries
CREATE INDEX IF NOT EXISTS idx_boundaries ON planet_osm_line USING GIST (way) WHERE boundary = 'administrative';

-- Indexes for place labels
CREATE INDEX IF NOT EXISTS idx_places ON planet_osm_point USING GIST (way) WHERE place IN ('city', 'town', 'village', 'hamlet');

-- Analyze tables for better query planning
ANALYZE planet_osm_point;
ANALYZE planet_osm_line;
ANALYZE planet_osm_polygon;
