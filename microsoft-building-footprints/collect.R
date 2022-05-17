
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

# Instead of writing 50 files, accumulate files until we hit the 2 GB limit
# to reduce the number of files we have to include in the release
library(arrow, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(geoarrow)

src_files <- tibble::tibble(
  src = file.path(
    "microsoft-building-footprints/geoparquet",
    stringr::str_replace(states, "\\.geojson.zip$", ".parquet")
  ),
  src_size = file.size(src) / 1e6
) %>%
  arrange(desc(src_size))

file_groups <- list()

while (nrow(src_files) > 0) {
  total_size <- 0
  this_group <- integer()
  for (i in seq_len(nrow(src_files))) {
    if ((total_size + src_files$src_size[i]) < 2000) {
      this_group[length(this_group) + 1] <- i
      total_size <- total_size + src_files$src_size[i]
    }
  }

  file_groups[[length(file_groups) + 1]] <- src_files$src[this_group]
  src_files <- src_files %>% slice(-this_group)
}

purrr::iwalk(file_groups, function(grp, i) {
  out_f <- glue::glue("microsoft-building-footprints/microsoft-building-footprints-{i}.parquet")
  message(out_f)

  stream <- FileOutputStream$create(out_f)
  writer <- NULL

  # do this one file at a time to hopefully avoid out-of-memory
  for (f in grp) {
    message(glue::glue("* {f}"))

    state <- f %>%
      basename() %>%
      stringr::str_remove("\\.parquet$") %>%
      stringr::str_replace_all("([a-z])([A-Z])", "\\1 \\2") %>%
      stringr::str_replace("Districtof", "District of")

    table <- arrow::read_parquet(f, col_select = "geometry", as_data_frame = FALSE)
    table_geom <- geoarrow::as_geoarrow(
      table$geometry,
      schema_override = geoarrow::geoarrow_schema_wkb()
    )

    message("convert")
    table_geom_geoarrow <- geoarrow::geoarrow(table_geom)

    # don't know why this gets dropped
    wk::wk_crs(table_geom_geoarrow) <- wk::wk_crs_proj_definition(
      sf::st_crs("OGC:CRS84"),
      verbose = TRUE
    )

    message("recreate table")
    table$geometry <- table_geom_geoarrow
    meta <- geoarrow:::geoparquet_metadata(
      narrow::as_narrow_schema(table$schema),
      primary_column = "geometry",
      arrays = list(narrow::as_narrow_array(table_geom_geoarrow))
    )

    # nix the bbox because we will be incrementally writing this
    meta$columns$geometry$bbox <- NULL

    table$state <- state
    table <- table[c("state", "geometry")]

    table$metadata$geo <- jsonlite::toJSON(
      meta,
      null = "null",
      auto_unbox = TRUE,
      always_decimal = TRUE
    )

    if (is.null(writer)) {
      writer <- ParquetFileWriter$create(
        table$schema,
        stream,
        properties = ParquetWriterProperties$create(
          column_names = "geometry",
          compression = "zstd",
          write_statistics = FALSE
        )
      )
    }

    message("write")
    writer$WriteTable(table, 2 ^ 20)
  }

  writer$Close()
  stream$close()
})

github_release_files <- list.files(
  "microsoft-building-footprints",
  "[0-9]\\.parquet$",
  full.names = TRUE
)

writeLines(github_release_files, "microsoft-building-footprints/github-release-files.txt")
