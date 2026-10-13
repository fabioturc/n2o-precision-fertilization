# Scripts

R scripts implementing the flux footprint modelling chain and the GIS export.

**Working directory: the repository root.** Open
`../n2o-precision-fertilization.Rproj` in RStudio (or `setwd()` to the repository root)
before running any of these scripts — all paths inside them are relative to the root.

Run them in ascending numerical order. Their output is consumed by
`../notebooks/00_footprint_weighted_averaging.ipynb`.

---

## Pipeline

* **`00_prep_footprint_input.R`**
  Builds the half-hourly input table required by the FFP model from the
  quality-filtered eddy covariance data and the modelled canopy height (used to derive
  the displacement height as 2/3 of the canopy height). Filters out records the model
  cannot process (`zm/L < -15.5`, `u_mean <= 0.1`) and records without a valid N&#8322;O flux.
  *Input:* `data/raw/fluxes_meteo_mgmt.parquet` (read with `arrow::read_parquet()`, only the
  needed columns), `data/raw/canopy_height_model.csv`
  *Output:* `data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv`

* **`01_footprint_climatology.R`**
  Computes aggregated footprint climatologies (Kljun et al., 2015) on a
  200 &#215; 200 m domain at 1 m resolution, for the 20 days following each of the three
  fertilization events, for the whole wheat period and for the following grassland
  period — each split into all / daytime / nighttime conditions.
  *Input:* `data/processed/footprint/FFP_input_CH-TAN_2023-2025.csv`
  *Output:* `data/processed/footprint/kljun_climatology/{fclim,x,y}_2d_*.csv` and
  `Routput_*.png`

* **`02_footprint_export_gis.R`**
  Converts the climatology matrices into GIS layers for QGIS: a cumulative
  contribution raster, a source-weight raster, the source-area isopleths as a
  shapefile, and a point table.
  *Input / output:* `data/processed/footprint/kljun_climatology/`

---

## `functions/`

* **`calc_footprint_FFP.R`**, **`calc_footprint_FFP_climatology.R`** — the reference
  implementation of the two-dimensional flux footprint parameterisation and its
  climatology by Kljun, N., Calanca, P., Rotach, M. W., and Schmid, H. P. (2015):
  *A simple two-dimensional parameterisation for Flux Footprint Prediction (FFP)*,
  Geosci. Model Dev., 8, 3695–3713, https://doi.org/10.5194/gmd-8-3695-2015.
  Obtained from https://footprint.kljun.net/ and unmodified apart from formatting.
  `calc_footprint_FFP_climatology.R` requires the Bioconductor package `EBImage`.
  Only the climatology function is used by the pipeline above; `calc_footprint_FFP.R`
  is the single-footprint version, kept alongside it for reference.
