# ---------------------------------------------------------------------------
# 00_prep_footprint_input.R
#
# Builds the half-hourly input table required by the Kljun et al. (2015)
# flux footprint model (FFP) from the quality-filtered eddy covariance data
# and the modelled canopy height (used to derive the displacement height).
#
# Input : data/raw/fluxes_meteo_mgmt.parquet
#         data/raw/canopy_height_model.csv
# Output: data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv
#
# Working directory: repository root (open n2o-precision-fertilization.Rproj).
# ---------------------------------------------------------------------------

library(openair)
library(tidyverse)
library(ggpubr)
library(arrow)   # to read the flux product, which is stored as parquet

TZ = "Etc/GMT-1"  # site time zone (CET, UTC+1, no daylight saving)

# Prepare input files-----------------------------------------------------
## Opening and processing data -------------------------------------------
# read the file
START_DATE = '2023-11-01'
END_DATE = '2025-06-05'
data.canopy_height = read.csv('data/raw/canopy_height_model.csv') %>%
  dplyr::select(TIMESTAMP_MIDDLE, can_height_mean) %>%
  mutate(TIMESTAMP_MIDDLE = as.POSIXct(TIMESTAMP_MIDDLE, format = '%Y-%m-%d %H:%M:%S', tz = TZ))

# Read only the ones needed here.
# TIMESTAMP_MIDDLE is the (time zone naive) index of the parquet file; arrow
# hands it back labelled as UTC, so re-anchor the wall clock time to TZ to
# make it comparable with the canopy height timestamps.
eddy_cols = c('TIMESTAMP_MIDDLE', 'WS', 'USTAR', 'WD', 'MO_LENGTH', 'V_SIGMA',
              'SW_IN_POT', 'FN2O_L3.3_CUT_50_QCF_footprint')
data.eddy = read_parquet("data/raw/fluxes_meteo_mgmt.parquet", col_select = all_of(eddy_cols)) %>%
  mutate(TIMESTAMP_MIDDLE = as.POSIXct(format(TIMESTAMP_MIDDLE, '%Y-%m-%d %H:%M:%S'),
                                       format = '%Y-%m-%d %H:%M:%S', tz = TZ))
# Merge the files
data.wind = left_join(data.canopy_height, data.eddy, by = "TIMESTAMP_MIDDLE")
############# KEEP ONLY DATA WHEN WE HAD AT LEAST QUALITY 1 ####################
# This is because we are interested to know where the quality controlled measured flux comes from
data.wind = data.wind %>%
    filter(!is.na(FN2O_L3.3_CUT_50_QCF_footprint)) %>%
  mutate(datetime = TIMESTAMP_MIDDLE,  # already POSIXct in TZ
         Year = format(datetime, '%Y'),
         Month = format(datetime, '%m'),
         Day = format(datetime, '%d'),
         Hour = format(datetime, '%H'),
         Minute = format(datetime, '%M'),
         zm = 2.03, # sonic height was 2.17 m
         z0 = -999,
         sigma_v = V_SIGMA, 
         d = round(can_height_mean / 100 * 2 / 3, 3) # displacement height --> 2/3 of canopy height
         ) %>% 
  filter(datetime >= as.POSIXct(START_DATE, tz = TZ) &
           datetime <= as.POSIXct(END_DATE, tz = TZ)) %>%
  mutate(across(everything(), ~as.numeric(as.character(.)))) %>%
  rename(u_mean = WS,
         u_star = USTAR,
         wind_dir = WD,
         L = MO_LENGTH) %>%
  dplyr::select(Year, Month, Day, Hour, Minute, zm, d, z0, u_mean, L, sigma_v, u_star, wind_dir, SW_IN_POT) %>%
  drop_na() # FFP doesn't work with NAs 

# Remove data below ustar threshold 

str(data.wind)
summary(data.wind)

# filter out values that cannot be processed by FFP
data.wind <- data.wind %>%
  filter( zm/L >= -15.5 & u_mean >0.1)

## Write csv file-----------------------------------------------------------
dir.create('data/processed/footprint', recursive = TRUE, showWarnings = FALSE)
write.csv(data.wind, 'data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv', row.names = FALSE)

