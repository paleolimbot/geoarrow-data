
# Philadelphia Parking Violations 2012-2017

The [Philadelphia Parking Violations](https://www.opendataphilly.org/dataset/parking-violations) data set is a collection of parking violations that has been used in several blog posts:

- https://www.crunchydata.com/blog/parquet-and-postgres-in-the-data-lake
- https://www.crunchydata.com/blog/performance-and-spatial-joins
- https://martinfleischmann.net/dask-geopandas-vs-postgis-vs-gpu-performance-and-spatial-joins/
- https://dewey.dunnington.ca/post/2022/profiling-point-in-polygon-joins-in-r/

The version referenced here contains data regarding ~9 million parking infractions from 2011 to 2017. The license for this data set is ambiguous regarding redistribution, so instead of providing a copy we provide the a link for downloading it directly from Open Data Philly:

The neighbourhoods polygon layer was obtained from the [Avavea geo-data repository](https://github.com/azavea/geo-data/tree/master/Neighborhoods_Philadelphia) and is released under the Creative Commons 3.0 license; please refer to http://creativecommons.org/licenses/by/3.0/us/ and attribute the data to Azavea Inc.

## Data

- [phl-neighbourhoods.parquet](https://github.com/paleolimbot/geoarrow-public-data/raw/master/phl-parking/phl-neighbourhoods.parquet)
- [phl-parking.csv](https://phl.carto.com/api/v2/sql?filename=parking_violations&format=csv&skipfields=cartodb_id,the_geom,the_geom_webmercator&q=SELECT%20*%20FROM%20parking_violations%20WHERE%20issue_datetime%20%3E=%20%272012-01-01%27%20AND%20issue_datetime%20%3C%20%272017-12-31%27)
