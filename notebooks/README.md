# Notebooks

Jupyter notebooks used to run the analyses and to generate the figures and tables of
the manuscript (see the top-level `README.md` for the full citation).

All notebooks are designed to run with the conda environment defined in
`../environment.yml`. Paths are relative to **this folder** (`../data/`, `../figures/`),
so the notebooks run as-is in Jupyter without changing the working directory.

---

## Naming and execution order

Notebooks are numbered by the stage they belong to:

* `00_*` — preprocessing / derived quantities that later steps build on
* `10_*` — main manuscript figures and tables
* `20_*` — supplementary figures

To reproduce the results, run them in ascending numerical order. Within the same
number the notebooks are independent of each other. The footprint climatologies that
`00_footprint_weighted_averaging.ipynb` is using as input are produced beforehand by the R
scripts in `../scripts/` (see `../scripts/README.md`).

---

## Notebook descriptions

* **`00_footprint_weighted_averaging.ipynb`**
  Reads the aggregated footprint climatologies from
  `../data/processed/footprint/kljun_climatology/` and the as-applied fertilization and
  wheat yield maps from `../data/raw/GIS/`. Rasterizes the maps onto the footprint grid,
  applies the treatment parcel masks, and computes both the footprint-weighted and the
  arithmetic mean applied N rate and grain yield per treatment. Outputs the summary
  statistics reported in the manuscript.

* **`10_env_and_fluxes_fig.ipynb`**
  Generates the overview figure of precipitation, soil water content, soil and air
  temperature together with the gap-filled NEE, N2O and CH4 fluxes for both
  treatments. Writes `../figures/env+NEE+N2O_*.png` and `../figures/env+CH4_*.png`.

* **`10_fluxes_fig.ipynb`**
  Generates the N2O flux time series and cumulative emission figures.
  Writes `../figures/Timeseries_*.png` and `../figures/Timeseries+cumulative_*.png`.

* **`10_manual_vegetation_measurements_fig.ipynb`**
  Reads the manual field measurements from `../data/raw/` (LAI, canopy height, dry
  biomass, crop N) and generates the figures of the
  vegetation development and the crop N diagnostics per treatment. Writes
  `../figures/veg_measurements_wheat.png` and `../figures/N_diagnostics_wheat.png`.

* **`10_soil_N_vs_N2O_fig.ipynb`**
  Accumulates N2O fluxes over the periods corresponding to the PRS probe burials and
  the soil samplings, relates them to nitrate-PRS supply and Nmin stocks, and computes
  the associated regression statistics. Writes `../figures/soilN_vs_N2O.png`.

* **`10_yield_and_N_use_efficiency.ipynb`**
  Computes the agronomic efficiency (AE), recovery efficiency of N (REN),
  physiological efficiency (PEN) and the N balance from the plot-level harvest data,
  and compares the two fertilization strategies. Writes `../figures/yield.png` and the
  statistics of the manuscript table.

* **`10_N_and_GHG_budgets.ipynb`**
  Converts the gap-filled fluxes to budget units, accumulates them over the manuscript
  periods with propagated uncertainties, and derives the N budget, the N2O emission
  factors and the net greenhouse gas exchange per treatment. Outputs the budget tables
  reported in the manuscript.

* **`20_diel_fluxes_fig.ipynb`**
  Supplementary figure of the mean diel cycles of N2O, CH4, and NEE per
  treatment and for the full footprint. Writes `../figures/*_diel.png`.

---

## `plot_config.py`

Shared plotting configuration imported by the notebooks:

* `COLORS` and `LABELS` — colours and legend labels of the two treatments
  (`A` = business-as-usual, `B` = variable rate application).
* `EVENT_LINES` — management events (sowing, each fertilization with its rate,
  harvest, harrowing, cultivation) drawn as annotated vertical lines.
* `PERIODS` — the period definitions used throughout the manuscript.
* `add_event_lines(ax, ...)` — helper that draws the events on a given axis,
  optionally restricted to a date range.

---

## Reproducibility notes

* Notebooks are intended to be run top-to-bottom without skipping cells.
* No manual editing is required to reproduce the manuscript results, provided the raw
  data are in place (see `../data/raw/README.md`).
