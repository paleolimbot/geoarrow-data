
release_files <- c(
  readr::read_lines("geofabrik-osm-denmark/github-release-files.txt"),
  readr::read_lines("microsoft-building-footprints/github-release-files.txt"),
  readr::read_lines("phl-parking/github-release-files.txt")
)

if (dir.exists("release-files")) {
  unlink("release-files", recursive = TRUE)
}

dir.create("release-files")
stopifnot(all(file.copy(release_files, "release-files")))
