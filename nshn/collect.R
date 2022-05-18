
library(tidyverse)
library(sf)
library(geoarrow)
library(arrow, warn.conflicts = FALSE)

# these have to get downloaded manually at:
# https://nsgi.novascotia.ca/gdd/
# (because the site requires a manual license acknowledgement)
shp_files <- list.files("nshn/nshn_v2", "\\.shp$", full.names = TRUE)

# convert to geoparquet/gpkg using ogr2ogr because sf has trouble with the mixed
# dimension types (introduced in latest GDAL)
gp_files <- shp_files %>%
  str_replace("/nshn_v2/", "/geoparquet/") %>%
  str_replace("\\.shp$", ".parquet") %>%
  str_replace("/nshn_v2", "/nshn") %>%
  str_replace("_ba_", "_basin_") %>%
  str_replace("_la_", "_land_") %>%
  str_replace("_wa_", "_water_")

gpkg_files <- gp_files %>%
  str_replace("\\.parquet", ".gpkg") %>%
  str_replace("/geoparquet/", "/")

final_parquet_files <- gp_files %>%
  str_replace("/geoparquet/", "/")

for (i in seq_along(shp_files)) {
  cmd <- glue::glue("ogr2ogr {gp_files[i]} {shp_files[i]}")
  message(cmd)
  system(cmd)

  cmd <- glue::glue("ogr2ogr {gpkg_files[i]} {gp_files[i]}")
  message(cmd)
  system(cmd)

  message("Converting parquet to geoarrow encoding")
  table <- geoarrow::read_geoparquet(gp_files[i])

  # again have to fix the crs getting dropped
  old_crs <- wk::wk_crs(table$geometry)
  table$geometry <- geoarrow::geoarrow(table$geometry)
  wk::wk_crs(table$geometry) <- old_crs
  table2 <- geoarrow::as_geoarrow_table(
    table,
    schema = narrow::as_narrow_schema(table$geometry),
    geoparquet_metadata = TRUE
  )
  write_parquet(
    table2,
    final_parquet_files[i],
    compression = "zstd"
  )
}

# just copy the data dictionary files into this dir and git them
file.copy(
  c("nshn/nshn_v2/NSHN Attribute_Specs.pdf", "nshn/nshn_v2/NSHN_FEATURECODES.txt"),
  "nshn"
)
file.rename("nshn/NSHN_FEATURECODES.txt", "nshn/nshn_feature_code.csv")

github_release_files <- list.files(
  "nshn",
  "\\.(gpkg|parquet)$",
  full.names = TRUE
)

writeLines(github_release_files, "nshn/github-release-files.txt")
