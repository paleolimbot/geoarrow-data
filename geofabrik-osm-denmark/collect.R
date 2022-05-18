
library(tidyverse)
library(sf)
library(arrow)
library(geoarrow)

if (!file.exists("geofabrik-osm-denmark/denmark-latest-free.shp.zip")) {
  curl::curl_download(
    "https://download.geofabrik.de/europe/denmark-latest-free.shp.zip",
    "geofabrik-osm-denmark/denmark-latest-free.shp.zip"
  )

  unzip("geofabrik-osm-denmark/denmark-latest-free.shp.zip", exdir = "geofabrik-osm-denmark")
}

shp_files <- list.files("geofabrik-osm-denmark", ".shp$", full.names = TRUE) %>%
  str_subset("buildings|roads|waterways|railways|places_f")
names <- shp_files %>%
  basename() %>%
  str_remove("_free.*?shp$") %>%
  str_replace("^gis_osm_", "geofabrik-osm-denmark-")

for (i in seq_along(shp_files)) {
  message(shp_files[i])

  table <- read_sf(shp_files[i]) %>%
    sf::st_transform("OGC:CRS84") %>%
    as_tibble() %>%
    as_geoarrow_table(geoparquet_metadata = TRUE)

  write_parquet(
    table,
    glue::glue("geofabrik-osm-denmark/{names[i]}.parquet"),
    compression = "zstd"
  )
}


github_release_files <- list.files(
  "geofabrik-osm-denmark",
  "\\.parquet$",
  full.names = TRUE
)

writeLines(github_release_files, "geofabrik-osm-denmark/github-release-files.txt")
