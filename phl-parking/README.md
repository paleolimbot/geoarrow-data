
# Philadelphia Parking Violations 2012-2017

The [Philadelphia Parking Violations](https://www.opendataphilly.org/dataset/parking-violations) data set is a collection of parking violations that has been used in several blog posts:

- https://www.crunchydata.com/blog/parquet-and-postgres-in-the-data-lake
- https://www.crunchydata.com/blog/performance-and-spatial-joins
- https://martinfleischmann.net/dask-geopandas-vs-postgis-vs-gpu-performance-and-spatial-joins/
- https://dewey.dunnington.ca/post/2022/profiling-point-in-polygon-joins-in-r/

The version included here contains data regarding ~9 million parking infractions from 2012 to 2017.

The neighbourhoods polygon layer was obtained from the [Avavea geo-data repository](https://github.com/azavea/geo-data/tree/master/Neighborhoods_Philadelphia) and is released under the Creative Commons 3.0 license; please refer to http://creativecommons.org/licenses/by/3.0/us/ and attribute the data to Azavea Inc.

Both files are written as GeoArrow-encoded Parquet files.
