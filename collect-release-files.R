
release_files <- c(
  readr::read_lines("geofabrik-osm-denmark/github-release-files.txt"),
  readr::read_lines("microsoft-building-footprints/github-release-files.txt"),
  readr::read_lines("phl-parking/github-release-files.txt"),
  readr::read_lines("nshn/github-release-files.txt")
)

if (!dir.exists("release-files")) {
  dir.create("release-files")
}

files_to_copy <- release_files[!file.exists(file.path("release-files", basename(release_files)))]
stopifnot(all(file.copy(files_to_copy, "release-files")))
