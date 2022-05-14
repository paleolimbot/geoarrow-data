
base <- "https://usbuildingdata.blob.core.windows.net/usbuildings-v2"

states <- c("Alabama.geojson.zip", "Alaska.geojson.zip",
  "Arizona.geojson.zip", "Arkansas.geojson.zip", "California.geojson.zip",
  "Colorado.geojson.zip", "Connecticut.geojson.zip", "Delaware.geojson.zip",
  "DistrictofColumbia.geojson.zip", "Florida.geojson.zip", "Georgia.geojson.zip",
  "Hawaii.geojson.zip", "Idaho.geojson.zip", "Illinois.geojson.zip",
  "Indiana.geojson.zip", "Iowa.geojson.zip", "Kansas.geojson.zip",
  "Kentucky.geojson.zip", "Louisiana.geojson.zip", "Maine.geojson.zip",
  "Maryland.geojson.zip", "Massachusetts.geojson.zip", "Michigan.geojson.zip",
  "Minnesota.geojson.zip", "Mississippi.geojson.zip", "Missouri.geojson.zip",
  "Montana.geojson.zip", "Nebraska.geojson.zip", "Nevada.geojson.zip",
  "NewHampshire.geojson.zip", "NewJersey.geojson.zip", "NewMexico.geojson.zip",
  "NewYork.geojson.zip", "NorthCarolina.geojson.zip", "NorthDakota.geojson.zip",
  "Ohio.geojson.zip", "Oklahoma.geojson.zip", "Oregon.geojson.zip",
  "Pennsylvania.geojson.zip", "RhodeIsland.geojson.zip", "SouthCarolina.geojson.zip",
  "SouthDakota.geojson.zip", "Tennessee.geojson.zip", "Texas.geojson.zip",
  "Utah.geojson.zip", "Vermont.geojson.zip", "Virginia.geojson.zip",
  "Washington.geojson.zip", "WestVirginia.geojson.zip", "Wisconsin.geojson.zip",
  "Wyoming.geojson.zip")

if (!dir.exists("microsoft-building-footprints/zip")) {
  dir.create("microsoft-building-footprints/zip")
  for (state in states) {
    if (file.exists(file.path("microsoft-building-footprints/zip", state))) {
      next
    }

    message(state)
    curl::curl_download(
      file.path(base, state),
      file.path("microsoft-building-footprints/zip", state)
    )
  }
}

if (!dir.exists("microsoft-building-footprints/geojson")) {
  dir.create("microsoft-building-footprints/geojson")
  states_geojson <- stringr::str_remove(states, "\\.zip$")
  for (state in states_geojson) {
    if (file.exists(file.path("microsoft-building-footprints/geojson", state))) {
      next
    }

    message(state)
    unzip(
      file.path("microsoft-building-footprints/zip", paste0(state, ".zip")),
      exdir = "microsoft-building-footprints/geojson"
    )
  }
}

if (!dir.exists("microsoft-building-footprints/geoparquet")) {
  dir.create("microsoft-building-footprints/geoparquet")
  states_geoparquet <- stringr::str_replace(states, "\\.geojson.zip$", ".parquet")
  for (state in states_geoparquet) {
    if (file.exists(file.path("microsoft-building-footprints/geoparquet", state))) {
      next
    }

    message(state)

    geojson_file <- file.path(
      "microsoft-building-footprints/geojson",
      stringr::str_replace(state, ".parquet", ".geojson")
    )

    geoparquet_file <- file.path("microsoft-building-footprints/geoparquet", state)
    system(glue::glue("ogr2ogr {geoparquet_file} {geojson_file}"))
  }
}

library(arrow, warn.conflicts = FALSE)
library(geoarrow)

states_geoparquet <- file.path(
  "microsoft-building-footprints/geoparquet",
  stringr::str_replace(states, "\\.geojson.zip$", ".parquet")
)[2]

# workaround lack of wk methods in s2
wk_crs.s2_geography <- function(x, ...) NULL
wk_set_crs.s2_geography <- function(x, ...) x

# read to Table
table <- arrow::read_parquet(states_geoparquet, as_data_frame = FALSE)
df <- geoarrow::geoarrow_collect(table, handler = s2::s2_geography_writer(check = FALSE))
df$cell_id <- as.character(centroid_cells)

# use centroid as a proxy for location and sort. Use Arrow to do this and
# brute force the conversion to int64.
centroid_cells <-  s2::as_s2_cell(s2::s2_centroid(df$geometry))

table$centroid_cell <- Array$create(centroid_cells)


cell_order <- order(centroid_cells)


tbl <- read_geoparquet(states_geoparquet, )
tbl$centroid <-

cells <- unique(s2::s2_cell_parent(tbl$centroid, level = 2))

# start with face cells
cell <- tbl$centroid

node_id <- list(s2::s2_cell_parent(cells, level = 0))


