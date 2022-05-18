
# geoarrow-data

This repository is a collection of recipies to make a few large-ish data sets available in [GeoParquet](https://github.com/opengeospatial/geoparquet)/[GeoArrow](https://github.com/geopandas/geo-arrow-spec) format to facilitate testing, prototyping, and benchmarking implementations. See the [releases](https://github.com/paleolimbot/geoarrow-public-data/releases) section for ready-to-go downloadable files; see subdirectories for dataset information/the recipies used to download and write the files:

- [Microsoft U.S. Buliding Footprints](microsoft-building-footprints)
- [Philadelphia Parking Violations 2012-2017](phl-parking)
- [Geofabrik Open Street Map (Denmark)](geofabrik-osm-denmark)
- [Nova Scotia Hydrographic Network](nshn)

## [Microsoft U.S. Buliding Footprints](microsoft-building-footprints)

- [microsoft-building-footprints-1.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-1.parquet)
- [microsoft-building-footprints-2.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-2.parquet)
- [microsoft-building-footprints-3.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-3.parquet)
- [microsoft-building-footprints-4.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-4.parquet)
- [microsoft-building-footprints-5.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-5.parquet)
- [microsoft-building-footprints-6.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/microsoft-building-footprints-6.parquet)

## [Philadelphia Parking Violations 2012-2017](phl-parking)

- [phl-neighbourhoods.parquet](https://github.com/paleolimbot/geoarrow-public-data/raw/master/phl-parking/phl-neighbourhoods.parquet)
- [phl-parking.csv](https://phl.carto.com/api/v2/sql?filename=parking_violations&format=csv&skipfields=cartodb_id,the_geom,the_geom_webmercator&q=SELECT%20*%20FROM%20parking_violations%20WHERE%20issue_datetime%20%3E=%20%272012-01-01%27%20AND%20issue_datetime%20%3C%20%272017-12-31%27)

## [Geofabrik Open Street Map (Denmark)](geofabrik-osm-denmark)

- [geofabrik-osm-denmark-buildings_a.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/geofabrik-osm-denmark-buildings_a.parquet)
- [geofabrik-osm-denmark-places.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/geofabrik-osm-denmark-places.parquet)
- [geofabrik-osm-denmark-railways.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/geofabrik-osm-denmark-railways.parquet)
- [geofabrik-osm-denmark-roads.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/geofabrik-osm-denmark-roads.parquet)
- [geofabrik-osm-denmark-waterways.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/geofabrik-osm-denmark-waterways.parquet)

### [Nova Scotia Hydrographic Network](nshn)

### Metadata

- [NSHN Attribute_Specs.pdf](https://github.com/paleolimbot/geoarrow-public-data/raw/master/nshn/NSHN%20Attribute_Specs.pdf)
- [nshn_feature_code.csv](https://github.com/paleolimbot/geoarrow-public-data/raw/master/nshn/nshn_feature_code.csv)

### GeoParquet

- [nshn_basin_line.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_line.parquet)
- [nshn_basin_point.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_point.parquet)
- [nshn_basin_poly.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_poly.parquet)
- [nshn_land_poly.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_land_poly.parquet)
- [nshn_water_cent.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_cent.parquet)
- [nshn_water_junc.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_junc.parquet)
- [nshn_water_line.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_line.parquet)
- [nshn_water_point.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_point.parquet)
- [nshn_water_poly.parquet](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_poly.parquet)

### GeoPackage

- [nshn_basin_line.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_line.gpkg)
- [nshn_basin_point.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_point.gpkg)
- [nshn_basin_poly.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_basin_poly.gpkg)
- [nshn_land_poly.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_land_poly.gpkg)
- [nshn_water_cent.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_cent.gpkg)
- [nshn_water_junc.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_junc.gpkg)
- [nshn_water_line.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_line.gpkg)
- [nshn_water_point.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_point.gpkg)
- [nshn_water_poly.gpkg](https://github.com/paleolimbot/geoarrow-public-data/releases/download/v0.0.1/nshn_water_poly.gpkg)
