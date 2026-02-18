/**
 * Dark Theme Stylesheet for OpenStreetMap
 * Inspired by OpenFreeMap Dark Style
 * 
 * Color Palette:
 * - Background: #0c0c0c (rgb(12,12,12))
 * - Water: #1b1b1d (rgb(27,27,29))
 * - Buildings: #0a0a0a (rgb(10,10,10))
 * - Roads: #121212 (dark gray)
 * - Text: #656565 (rgb(101,101,101))
 */

/* === BACKGROUND === */
Map {
  background-color: #0c0c0c;
}

/* === WATER === */
#water-areas {
  polygon-fill: #1b1b1d;
  polygon-opacity: 1;
}

#water-lines {
  line-color: #1b1b1d;
  line-width: 1;
  [zoom >= 12] { line-width: 2; }
  [zoom >= 14] { line-width: 3; }
}

#waterway {
  line-color: #1b1b1d;
  line-width: 0.5;
  [zoom >= 12] { line-width: 1; }
  [zoom >= 14] { line-width: 2; }
  [zoom >= 16] { line-width: 3; }
}

/* === LANDUSE === */
#landuse {
  [landuse = 'residential'] {
    polygon-fill: #0d0d0d;
    polygon-opacity: 0.4;
  }
  [landuse = 'forest'],
  [natural = 'wood'] {
    polygon-fill: #202020;
    polygon-opacity: 0.8;
  }
  [leisure = 'park'] {
    polygon-fill: #202020;
    polygon-opacity: 1;
  }
  [landuse = 'grass'] {
    polygon-fill: #1a1a1a;
  }
}

/* === BUILDINGS === */
#buildings {
  polygon-fill: #0a0a0a;
  polygon-opacity: 1;
  line-color: #1b1b1d;
  line-width: 0.5;
  [zoom >= 14] { line-width: 1; }
}

/* === ROADS === */
#roads {
  [highway = 'motorway'] {
    line-color: #000000;
    line-width: 1;
    [zoom >= 10] { line-width: 2; }
    [zoom >= 12] { line-width: 4; }
    [zoom >= 14] { line-width: 6; }
    [zoom >= 16] { line-width: 8; }
    ::outline {
      line-color: #3c3c3c;
      line-width: 1.5;
      [zoom >= 10] { line-width: 3; }
      [zoom >= 12] { line-width: 5; }
      [zoom >= 14] { line-width: 7; }
      [zoom >= 16] { line-width: 9; }
    }
  }
  
  [highway = 'trunk'],
  [highway = 'primary'],
  [highway = 'secondary'],
  [highway = 'tertiary'] {
    line-color: #121212;
    line-width: 1;
    [zoom >= 12] { line-width: 2; }
    [zoom >= 14] { line-width: 4; }
    [zoom >= 16] { line-width: 6; }
    ::outline {
      line-color: #3c3c3c;
      line-width: 1.5;
      [zoom >= 12] { line-width: 3; }
      [zoom >= 14] { line-width: 5; }
      [zoom >= 16] { line-width: 7; }
    }
  }
  
  [highway = 'residential'],
  [highway = 'unclassified'],
  [highway = 'service'] {
    line-color: #181818;
    line-width: 0.5;
    [zoom >= 14] { line-width: 2; }
    [zoom >= 16] { line-width: 4; }
  }
  
  [highway = 'path'],
  [highway = 'footway'],
  [highway = 'cycleway'] {
    line-color: #1b1b1d;
    line-width: 0.5;
    line-dasharray: 3,3;
    [zoom >= 16] { line-width: 1; }
  }
}

/* === RAILWAYS === */
#railway {
  [railway = 'rail'] {
    line-color: #232323;
    line-width: 1;
    [zoom >= 12] { line-width: 2; }
    [zoom >= 14] { line-width: 3; }
    ::dashes {
      line-color: #0c0c0c;
      line-width: 0.5;
      line-dasharray: 6,6;
      [zoom >= 12] { line-width: 1; }
      [zoom >= 14] { line-width: 1.5; }
    }
  }
}

/* === BOUNDARIES === */
#boundaries {
  [admin_level = '2'] {
    line-color: #3a3a3a;
    line-width: 1;
    line-dasharray: 4,4;
    [zoom >= 6] { line-width: 2; }
  }
  [admin_level = '4'] {
    line-color: #353535;
    line-width: 0.5;
    line-dasharray: 3,3;
    [zoom >= 8] { line-width: 1; }
  }
}

/* === TEXT LABELS === */
#place-labels {
  text-name: [name];
  text-face-name: "DejaVu Sans Book";
  text-fill: #656565;
  text-halo-fill: rgba(0, 0, 0, 0.7);
  text-halo-radius: 1;
  text-size: 10;
  text-transform: uppercase;
  
  [place = 'city'] {
    text-size: 14;
    [zoom >= 8] { text-size: 16; }
  }
  [place = 'town'] {
    text-size: 12;
    [zoom >= 10] { text-size: 14; }
  }
  [place = 'village'] {
    text-size: 10;
    [zoom >= 12] { text-size: 12; }
  }
}

#road-labels {
  text-name: [name];
  text-face-name: "DejaVu Sans Book";
  text-fill: #504e4e;
  text-halo-fill: rgba(0, 0, 0, 1);
  text-halo-radius: 1;
  text-size: 10;
  text-placement: line;
  text-max-char-angle-delta: 20;
  text-transform: uppercase;
  text-spacing: 300;
}
