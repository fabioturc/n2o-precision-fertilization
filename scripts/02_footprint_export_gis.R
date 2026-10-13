# ---------------------------------------------------------------------------
# 02_footprint_export_gis.R
#
# Converts the footprint climatology matrices into GIS layers: a cumulative
# contribution raster, a source-weight raster, the source-area isopleths
# (50/70/90 %) as a shapefile, and a point table, all for use in QGIS.
#
# Input : data/processed/footprint/kljun_climatology/{fclim,x,y}_2d_*_ALL_*.csv
# Output: data/processed/footprint/kljun_climatology/ffp_*.{tif,shp,csv}
#
# Working directory: repository root (open n2o-precision-fertilization.Rproj).
# ---------------------------------------------------------------------------

library(dplyr)
library(stringr)
library(readr)
library(terra)
library(sf)

data_dir <- "data/processed/footprint/kljun_climatology"
files <- list.files(data_dir, full.names = TRUE)

crop <- "Wheat"

fclim_file <- files[str_detect(basename(files), paste0("^fclim_2d_", crop, ".*_ALL_.*\\.csv$"))]
x_file     <- files[str_detect(basename(files), paste0("^x_2d_",     crop, ".*_ALL_.*\\.csv$"))]
y_file     <- files[str_detect(basename(files), paste0("^y_2d_",     crop, ".*_ALL_.*\\.csv$"))]

read_clean_matrix <- function(path) {
  x <- read.table(path, header = FALSE, sep = ",", stringsAsFactors = FALSE)
  m <- as.matrix(x[-1, -1, drop = FALSE])
  storage.mode(m) <- "numeric"
  m
}

fclim <- read_clean_matrix(fclim_file)
x_2d  <- read_clean_matrix(x_file)
y_2d  <- read_clean_matrix(y_file)

stopifnot(all(dim(fclim) == dim(x_2d)), all(dim(fclim) == dim(y_2d)))

# Tower location in EPSG:2056
tower_easting  <- 2711032.546
tower_northing <- 1259910.034

# Grid resolution (dx, dy) consistent with the Kljun function
dx <- abs(mean(diff(x_2d[1, ])))
dy <- abs(mean(diff(y_2d[, 1])))
cell_area <- dx * dy

# x and y vectors as used by contourLines(x, y, t(fclim), ...)
x <- as.numeric(x_2d[1, ])
y <- as.numeric(y_2d[, 1])

# Create your cumulative surface raster (rank-based)
ffp_long <- tibble(
  x = as.vector(x_2d) + tower_easting,
  y = as.vector(y_2d) + tower_northing,
  value = as.vector(fclim)
) %>%
  mutate(contrib = value * cell_area) %>%
  arrange(desc(contrib)) %>%
  mutate(cumulative = cumsum(contrib) / sum(contrib))

r_cum <- rast(
  data.frame(x = ffp_long$x, y = ffp_long$y, z = ffp_long$cumulative),
  type = "xyz", crs = "EPSG:2056"
)

writeRaster(r_cum, file.path(data_dir, paste0("ffp_cum_", crop, ".tif")), overwrite = TRUE)

# Also export the footprint VALUE raster for reference (this is what Kljun contours)
df_val <- data.frame(
  x = as.vector(x_2d) + tower_easting,
  y = as.vector(y_2d) + tower_northing,
  z = as.vector(fclim)
)

r_val <- rast(df_val, type = "xyz", crs = "EPSG:2056")
writeRaster(r_val, file.path(data_dir, paste0("ffp_val_", crop, ".tif")), overwrite = TRUE)

# Kljun-style isopleths
rs <- c(0.70, 0.80, 0.90)

f_sort <- sort(c(fclim), decreasing = TRUE)
f_sort <- f_sort[!is.na(f_sort)]
f_cum  <- cumsum(f_sort) * dx * dy

# helper: make sf from contourLines output, with rounding to 0.1 and ring closing
contours_to_sf <- function(contour_list, r_frac, fr_level, tower_e, tower_n) {
  geoms <- lapply(contour_list, function(one) {
    cx <- round(one$x * 10) / 10
    cy <- round(one$y * 10) / 10
    coords <- unique(cbind(cx, cy))
    if (nrow(coords) < 2) return(NULL)
    
    # close line
    coords <- rbind(coords, coords[1, , drop = FALSE])
    
    # shift to tower coordinates (if x/y are relative)
    coords[, 1] <- coords[, 1] + tower_e
    coords[, 2] <- coords[, 2] + tower_n
    
    st_linestring(coords)   # <-- lines, not polygons
  })
  
  geoms <- Filter(Negate(is.null), geoms)
  if (length(geoms) == 0) return(NULL)
  
  st_sf(
    r  = r_frac,
    fr = fr_level,
    geometry = st_sfc(geoms, crs = 2056)
  )
}


iso_sf_list <- list()

for (i in seq_along(rs)) {
  # find footprint value threshold fr closest to cumulative target rs[i]
  ind_r <- which.min(abs(f_cum - rs[i]))
  fr <- f_sort[ind_r]
  
  # IMPORTANT: transpose t(fclim) exactly like the Kljun code
  cl <- contourLines(x, y, t(fclim), levels = fr)
  
  sf_i <- contours_to_sf(cl, rs[i], fr, tower_easting, tower_northing)
  if (!is.null(sf_i)) iso_sf_list[[length(iso_sf_list) + 1]] <- sf_i
}

iso_sf <- do.call(rbind, iso_sf_list)

# write as a single shapefile (multiple features; attribute r is 0.5/0.7/0.9)
st_write(iso_sf,
         dsn = file.path(data_dir, paste0("ffp_isopleths_", crop, ".shp")),
         delete_dsn = TRUE)
