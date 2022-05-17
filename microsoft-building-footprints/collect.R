
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
library(dplyr, warn.conflicts = FALSE)
library(geoarrow)

# workaround lack of wk methods in s2
wk_crs.s2_geography <- function(x, ...) NULL
wk_set_crs.s2_geography <- function(x, ...) x

# get the arrow int64 representation of an s2 cell vector
infer_type.s2_cell <- function(x, ...) int64()
as_arrow_array.s2_cell <- function(x, ...) {
  cells_narrow <- narrow::narrow_array(
    narrow::narrow_schema("l"),
    narrow::narrow_array_data(
      length = length(x),
      null_count = 0,
      buffers = list(NULL, x)
    )
  )

  narrow::from_narrow_array(cells_narrow, arrow::Array)
}

states_geoparquet <- file.path(
  "microsoft-building-footprints/geoparquet",
  stringr::str_replace(states, "\\.geojson.zip$", ".parquet")
)

for (gp in states_geoparquet[44:length(states_geoparquet)]) {
  message(gp)

  state_name <- gp %>%
    stringr::str_remove(".*/geoparquet/") %>%
    stringr::str_remove(".parquet$") %>%
    stringr::str_replace("([a-z])([A-Z])", "\\1 \\2") %>%
    stringr::str_replace("Districtof", "District of")

  # read to Table
  table <- arrow::read_parquet(gp, as_data_frame = FALSE)

  # calculate the building centroid S2 cell for fun...also use the parent at level
  # 6 because that's a vaguely useful scale for this dataset
  df <- geoarrow::geoarrow_collect(table, col_names = "geometry", handler = s2::s2_geography_writer(check = FALSE))
  centroid_cells <-  s2::as_s2_cell(s2::s2_centroid(df$geometry))
  centroid_cell_parent_common <- s2::s2_cell_parent(centroid_cells, level = 4)

  table$s2_cell_centroid <- centroid_cells
  table$s2_cell_index <- centroid_cell_parent_common

  # sort along centroid but don't include it; include index cell so we can
  # group by it
  table_sorted <- table %>%
    arrange(s2_cell_centroid) %>%
    mutate(state = state_name) %>%
    select(state, s2_cell_index, release, capture_dates_range, geometry) %>%
    collect(as_data_frame = FALSE)

  # convert geometry to geoarrow encoding
  geom <- as_geoarrow(
    table_sorted$geometry,
    schema_override = geoarrow_schema_wkb()
  )
  # TODO: this shouldn't drop CRS but it does
  geom <- geoarrow(geom)
  wk::wk_crs(geom) <- sf::st_crs("OGC:CRS84")
  table_sorted$geometry <- geom

  write_dataset(
    table_sorted,
    "microsoft-building-footprints/dataset",
    partitioning = c("state", "s2_cell_index"),
    compression = "zstd"
  )
}
