
library(arrow, warn.conflicts = FALSE)
library(sf, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(geoarrow)

if (!file.exists("phl-parking/phl-parking.parquet")) {
  curl::curl_download(
    "https://phl.carto.com/api/v2/sql?filename=parking_violations&format=csv&skipfields=cartodb_id,the_geom,the_geom_webmercator&q=SELECT%20*%20FROM%20parking_violations%20WHERE%20issue_datetime%20%3E=%20%272012-01-01%27%20AND%20issue_datetime%20%3C%20%272017-12-31%27",
    "phl-parking/phl-parking.csv"
  )

  # read to Table, add projected geometry column, then write as parquet
  parking <- read_csv_arrow("phl-parking/phl-parking.csv", as_data_frame = FALSE)
  parking_coords <- cbind(parking$lon$as_vector(), parking$lat$as_vector())
  parking_coords_utm18 <- sf::sf_project("OGC:CRS84", "EPSG:26918", parking_coords)
  parking_coords_utm18[!is.finite(parking_coords_utm18)] <- NA_real_
  parking$geometry <- wk::xy(
    parking_coords_utm18[, 1],
    parking_coords_utm18[, 2],
    crs = sf::st_crs("EPSG:26918")
  )
  parking$lat <- NULL
  parking$lon <- NULL

  arrow::write_parquet(parking, "phl-parking/phl-parking.parquet", compression = "zstd")
}

if (!file.exists("phl-parking/phl-neighbourhoods.parquet")) {
  curl::curl_download(
    "https://github.com/azavea/geo-data/raw/master/Neighborhoods_Philadelphia/Neighborhoods_Philadelphia.zip",
    "phl-parking/Neighborhoods_Philadelphia.zip"
  )

  unzip("phl-parking/Neighborhoods_Philadelphia.zip", exdir = "phl-parking")
  read_sf("phl-parking/Neighborhoods_Philadelphia.shp") %>%
    sf::st_transform("EPSG:26918") %>%
    tibble::as_tibble() %>%
    arrow::write_parquet("phl-parking/phl-neighbourhoods.parquet", compression = "uncompressed")

  unlink(list.files("phl-parking", "^Neighborhoods_", full.names = TRUE))
  unlink("phl-parking/__MACOSX", recursive = TRUE)
}

# also write a dataset version
if (!dir.exists("phl-parking/dataset")) {
  read_parquet("phl-parking/phl-parking.parquet") %>%
    mutate(
      year = lubridate::year(issue_datetime)
    ) %>%
    filter(year >= 2012) %>%
    group_by(year) %>%
    write_dataset("phl-parking/dataset")
}

github_release_files <- c(
  # small enough for regular github
  # "phl-parking/phl-neighbourhoods.parquet",
  # the license is unclear here
  # "phl-parking/phl-parking.parquet"
)

writeLines(as.character(github_release_files), "phl-parking/github-release-files.txt")
