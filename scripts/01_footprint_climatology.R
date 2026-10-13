# ---------------------------------------------------------------------------
# 01_footprint_climatology.R
#
# Computes aggregated flux footprint climatologies (Kljun et al., 2015) for
# the periods of interest (each fertilization event, the whole wheat period
# and the following grassland period), separately for all / daytime /
# nighttime conditions.
#
# Note: isopleths are not computed here, as the aggregated climatology runs
# into an error for some periods.
#
# Input : data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv
# Output: data/processed/footprint/kljun_climatology/{fclim,x,y}_2d_*.csv
#         data/processed/footprint/kljun_climatology/Routput_*.png
#
# Working directory: repository root (open n2o-precision-fertilization.Rproj).
# ---------------------------------------------------------------------------

library(fields) # image.plot
library(lubridate)
library(tibble)
library(purrr)
source('scripts/functions/calc_footprint_FFP_climatology.R')

currdate <- format(Sys.Date(), format='%Y%m%d')

# load the data needed for fp, already in the right format
# Take half-hourly data, already in the right format
file <- 'data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv'
ffp.data <- read.csv(file)
ffp.data[ffp.data == -999] <- NaN # R functions need NaNs

# In calc_footprint_FFP zm represents: "Measurement height above displacement height (i.e. z‐d) [m]"
ffp.data$zm = ffp.data$zm - ffp.data$d

# Remove z0 column because it is all NANs and we use u_mean
ffp.data$z0 <- NULL

# omit NAs in the data, so that the calculation always works
dat <- na.omit(ffp.data)
(nvals <- nrow(ffp.data))

# test
#dat <- dat[1:5,]

# settings 
dd <- c(-200, 200, -200, 200) # domain
d.xy <- 1 # 1 meter

# Define period for which we want to calculate the avg footprint
dat$date = dat$Date <- make_date(dat$Year, dat$Month, dat$Day)
periods <- tribble(
  ~name,       ~from,            ~to,
  "Fert1", ymd("2024-03-05"), ymd("2024-03-25"), # 20 days following 1st fertilization
  "Fert2", ymd("2024-04-09"), ymd("2024-04-29"), # 20 days following 2nd fertilization
  "Fert3", ymd("2024-05-15"), ymd("2024-06-05"), # 20 days following 3rd fertilization
  "Wheat", ymd("2023-11-01"), ymd("2024-08-22"), # whole measurement period under wheat + post harvest
  "Grassland", ymd("2024-08-23"), ymd("2025-06-05") # whole measurement period under grassland
)

dir.create("data/processed/footprint/kljun_climatology", recursive = TRUE, showWarnings = FALSE)

for (i in seq_len(nrow(periods))) {
  sel <- dat$Date >= periods$from[i] & dat$Date <= periods$to[i]
  dat.curr <- dat[sel,]
  nvals <- nrow(dat.curr)
  
  # --- ALL fps (as before) ---
  output <- calc_footprint_FFP_climatology(
    dat.curr$zm, NaN, dat.curr$u_mean, rep(1000,nvals), dat.curr$L,
    dat.curr$sigma_v, dat.curr$u_star, dat.curr$wind_dir,
    domain = dd, dx = d.xy, dy = d.xy,
    nx = NULL, ny = NULL,
    r = seq(10, 80, 10),
    rslayer = 0, smooth_data = 0,
    crop = NULL, pulse = 1, fig = 1
  )
  
  imgfile <- paste0("data/processed/footprint/kljun_climatology/Routput_", periods$name[i],
                    "_", max(dd),"x",max(dd),"_",d.xy,"m_ALL_",currdate,".png")
  dev.copy(png, filename = imgfile, width = 1600, height = 1400, res = 200)
  dev.off()
  
  write.csv(output$fclim_2d,
            file=paste0("data/processed/footprint/kljun_climatology/fclim_2d_", periods$name[i],
                        "_", max(dd),"x",max(dd),"_",d.xy,"m_ALL_",currdate,".csv"))
  write.csv(output$x_2d,
            file=paste0("data/processed/footprint/kljun_climatology/x_2d_", periods$name[i],
                        "_", max(dd),"x",max(dd),"_",d.xy,"m_ALL_",currdate,".csv"))
  write.csv(output$y_2d,
            file=paste0("data/processed/footprint/kljun_climatology/y_2d_", periods$name[i],
                        "_", max(dd),"x",max(dd),"_",d.xy,"m_ALL_",currdate,".csv"))
  
  base_all <- paste0(periods$name[i], "_", max(dd),"x",max(dd), "_", d.xy, "m_ALL_", currdate)
  
  # --- DAY vs NIGHT ---
  for (period_type in c("Day","Night")) {
    if (period_type == "Day") {
      dat.sub <- dat.curr[dat.curr$SW_IN_POT > 0, ]
    } else {
      dat.sub <- dat.curr[dat.curr$SW_IN_POT == 0, ]
    }
    
    if (nrow(dat.sub) == 0) next  # skip if no data
    
    nvals <- nrow(dat.sub)
    output <- calc_footprint_FFP_climatology(
      dat.sub$zm, NaN, dat.sub$u_mean, rep(1000,nvals), dat.sub$L,
      dat.sub$sigma_v, dat.sub$u_star, dat.sub$wind_dir,
      domain = dd, dx = d.xy, dy = d.xy,
      nx = NULL, ny = NULL,
      r =  seq(10, 80, 10),
      rslayer = 0, smooth_data = 0,
      crop = NULL, pulse = 1, fig = 1
    )
    
    imgfile <- paste0("data/processed/footprint/kljun_climatology/Routput_", periods$name[i],
                      "_", max(dd),"x",max(dd),"_",d.xy,"m_",period_type,"_",currdate,".png")
    dev.copy(png, filename = imgfile, width = 1600, height = 1400, res = 200)
    dev.off()
    
    write.csv(output$fclim_2d,
              file=paste0("data/processed/footprint/kljun_climatology/fclim_2d_", periods$name[i],
                          "_", max(dd),"x",max(dd),"_",d.xy,"m_",period_type,"_",currdate,".csv"))
    write.csv(output$x_2d,
              file=paste0("data/processed/footprint/kljun_climatology/x_2d_", periods$name[i],
                          "_", max(dd),"x",max(dd),"_",d.xy,"m_",period_type,"_",currdate,".csv"))
    write.csv(output$y_2d,
              file=paste0("data/processed/footprint/kljun_climatology/y_2d_", periods$name[i],
                          "_", max(dd),"x",max(dd),"_",d.xy,"m_",period_type,"_",currdate,".csv"))
  }
}






