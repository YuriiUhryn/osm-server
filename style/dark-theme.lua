-- Dark theme Lua transformation script for osm2pgsql
-- Based on openstreetmap-carto with modifications for dark rendering

-- Objects with any of the following keys will be treated as polygon
local polygon_keys = {
    'aeroway',
    'amenity',
    'area',
    'barrier',
    'boundary',
    'building',
    'craft',
    'golf',
    'harbour',
    'historic',
    'landuse',
    'leisure',
    'man_made',
    'military',
    'natural',
    'office',
    'place',
    'power',
    'public_transport',
    'shop',
    'sport',
    'tourism',
    'water',
    'waterway',
    'wetland'
}

-- Objects with any of the following key/value combinations will be treated as polygon
local polygon_tags = {
    aerialway = {station = true},
    highway = {services = true, rest_area = true},
    railway = {station = true}
}

-- Initialize Lua logic
function init_function()
end

-- Clean tags
function exit_function()
end

-- Main way processing
function way_function(keyvalues, numberofkeys)
    local filter = false
    local roads = false
    
    if keyvalues["highway"] ~= nil then
        roads = true
    end
    
    if keyvalues["railway"] ~= nil then
        roads = true
    end
    
    return filter, roads
end

function select_relation_members()
    return {}
end
