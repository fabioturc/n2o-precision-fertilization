# Raw data

Input data used in the analyses (see the top-level `README.md` for the full citation).

**These data are not distributed with this repository.** They are archived in the ETH
Research Collection, DOI [10.3929/ethz-c-000807633](https://doi.org/10.3929/ethz-c-000807633), under
embargo until the associated article is published; access is granted on request until
then. Download the files from that record and place them directly in this folder,
keeping the names and the `GIS/` subfolder structure listed below.
All tabular files are plain-text CSV (comma-separated) with a header row or Apache Parquet files; all spatial
layers are ESRI shapefiles in **CH1903+ / LV95 (EPSG:2056)**.

Treatments are coded by **parcel**: `A` = business-as-usual (BAU), `B` = variable rate
application (VRA).

---

## 1. Content of this folder

The record listed above contains all files below. They are expected directly in
`data/raw/`, with the spatial layers under `data/raw/GIS/`.

### Field measurements

| File | Description |
|------|-------------|
| `LAI.csv` | Leaf area index of winter wheat from field campaigns. Columns: `date`, `LAI_mean`, `LAI_se`, `parcel`. |
| `canopy_height.csv` | Canopy height measurements (cm), one row per sample. Columns: `date`, `parcel`, `can_height`, `sample`. |
| `canopy_height_agg.csv` | Same data aggregated per date and parcel (mean, sd, count, se). |
| `crop_biomass.csv` | Aboveground crop biomass from destructive samplings, one row per sample: `dbm`/`fbm` (dry / fresh biomass, kg ha&#8315;&#185;), `n_percent`, `c_percent`, `d15n` (&#948;&#185;&#8309;N, &#8240;), `d13c` (&#948;&#185;&#179;C, &#8240;), `crop_n`, `crop_c` (kg ha&#8315;&#185;), `c_n_ratio`. |
| `crop_biomass_agg.csv` | Same data aggregated per date and parcel (mean, sd, count, se for each variable). |
| `Nmin.csv` | Soil mineral N from soil sampling and lab analysis, one row per date, parcel, plot and depth layer, combining two sampling schemes: **0–15 cm** manual sampling analysed for ammonium *and* nitrate (`nh4_*`, `no3_*`, their sum `Nmin_*`, ratios); **0–30, 30–60, 60–90 cm** machine-assisted sampling analysed for nitrate only (`nh4_*` and `Nmin_*` empty), with bulk density `bd_kg_m3` and stone content `skeleton` used for the area-based conversion; **0–90** the nitrate profile total (`no3_kgN_ha` only). Concentrations in mg N kg⁻¹ (`*_mgN_kg`), stocks in kg N ha⁻¹ (`*_kgN_ha`). |
| `Nmin_agg.csv` | Same data aggregated per date, parcel and depth layer (mean, sd, count, se for each variable); the ammonium and `Nmin` statistics are empty for the nitrate-only layers. |
| `PRS_nutrients.csv` | Plant Root Simulator (PRS) probe data: time-integrated NO&#8323;&#8315;-N supply per burial period, raw (`no3-n`) and normalised by burial duration (`no3-n_corr`), with `burial_dt`, `retrieval_dt` and `burial_duration`. |
| `PRS_nutrients_agg.csv` | Same data aggregated per date and parcel (mean, sd, count, se). |
| `yield.csv` | Plot-level harvest data (2024): `DM_straw`, `DM_grain` (dry matter yield), `TGW` (thousand grain weight), `ear_density`, `straw_N`, `grain_N`, treatment, replicate and plot coordinates. |

### Spatial layers

| File | Description |
|------|-------------|
| `GIS/fertilizations/fertilization_as_applied.shp` | As-applied fertilization map recorded by the spreader and processed by SmartN. The N rates actually applied in each of the three in-season applications are in the fields `N_APPLY1`, `N_APPLY2`, `N_APPLY3` (kg N ha&#8315;&#185;); `Total_N` / `Ntotal` give the season total. The remaining fields are the raw ISOBUS/machine attributes and are not used. |
| `GIS/yield/yield_map_wheat_2024.shp` | Winter wheat grain yield map (2024) from the combine harvester, pre-processed and interpolated by SmartN following the HAFL protocol, calibrated against the total weighed field yield, converted to dry matter using the moisture measured at weighing, and with polygons near the eddy covariance station (where the harvester was turning) removed manually. Yield in dry matter is in `t_ha_DM`. |

### Derived time series

| File | Description |
|------|-------------|
| `canopy_height_model.csv` | Half-hourly canopy height interpolated from the manual measurements, used in `scripts/00_prep_footprint_input.R` to derive the displacement height (2/3 of the canopy height). Columns: `TIMESTAMP_MIDDLE`, `can_height_mean`, `can_height_parcelA`, `can_height_parcelB`. |

### Fluxes and meteo data

The data are contained in an Apache Parquet file whose index is the half-hourly, time zone naive
timestamp `TIMESTAMP_MIDDLE`; the site time zone is CET (UTC+1, no daylight saving).

| File | Used by | Description |
|------|---------|-------------|
| `fluxes_meteo_mgmt.parquet` | `scripts/00_prep_footprint_input.R`, all `10_*` and `20_*` notebooks | Half-hourly subset of the CH-TAN wheat 2023-24 flux product (see below): measured and gap-filled eddy covariance fluxes (NEE, N&#8322;O, CH&#8324;) for the footprint and for each treatment parcel, the u&#42; threshold scenarios (`CUT_16/50/84`), the flux uncertainty terms incl. the gap-filling ensemble members (`_ens##`), turbulence and parcel attribution variables, and meteorological and soil variables. Read with `diive.core.io.files.load_parquet` (Python) or `arrow::read_parquet()` (R). |

**Origin.** `fluxes_meteo_mgmt.parquet` is the file
`90.3_CH-TAN_wheat_2023-24_FLUXES_METEO_MGMT_SUBSET_n2o-precision-fertilization.parquet` of the
CH-TAN wheat 2023-24 flux product, renamed. It is produced by notebook
`notebooks/90_FINAL_MERGE/90.0_MergeFluxesMeteoManagement.ipynb` of the repository
[dataset_ch-tan_wheat_2023-24_flux_product](https://github.com/fabioturc/dataset_ch-tan_wheat_2023-24_flux_product)
and archived with the full flux product in the ETH Research Collection, DOI:
[10.3929/ethz-c-000807457](https://doi.org/10.3929/ethz-c-000807457); the processing code is also archived on Zenodo. The
processing of the fluxes (quality control, u&#42; filtering, parcel attribution,
gap-filling and uncertainty estimation) is documented there. Please cite the flux
product when using these data.

---

## 2. How these data are used

* The R scripts in `../../scripts/` build the footprint model input and compute the
  footprint climatologies.
* The notebooks in `../../notebooks/` read these files directly, merge them, and
  generate the figures and tables of the manuscript.

No manual modification of the raw files is required to reproduce the analysis.

---

## 3. Citation

If you use these data, please cite the paper (see the top-level `README.md`) and the
ETH Research Collection records listed above.
