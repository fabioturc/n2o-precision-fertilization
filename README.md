# Code for: "TITLE PLACEHOLDER"

> **Status.** Pre-release accompanying a manuscript that is currently under review.
> The citation below, the release version and the access status of the data records
> will be updated once the article is published.

This repository contains the code used in the analysis for:

> Turco et al. (YEAR PLACEHOLDER).
> *Title placeholder.* *Journal Name PLACEHOLDER*.

The study compares business-as-usual (BAU) and variable rate application (VRA) N
fertilization of winter wheat at the Swiss cropland site **CH-TAN** (Tänikon), using
eddy covariance N2O, CH4 and CO2 flux measurements over two treatment
parcels, flux footprint modelling, manual field measurements and plot-level yield data.

---

## Repository structure

| Path | Content |
|------|---------|
| `notebooks/` | Jupyter notebooks used for all analyses and to generate the figures and tables. See `notebooks/README.md`. |
| `scripts/` | R scripts for the flux footprint modelling chain (Kljun et al., 2015) and the GIS export. See `scripts/README.md`. |
| `data/raw/` | Where the input data go. **No data are distributed with this repository** &#8212; download them from the ETH Research Collection (see *Data availability* below) into this folder; `data/raw/README.md` documents every file. |
| `data/processed/` | Intermediate data created by the scripts and notebooks. |
| `figures/` | Output figures corresponding to the manuscript (and additional diagnostic figures). |
| `environment.yml` | Conda environment file to reproduce the Python setup. |
| `n2o-precision-fertilization.Rproj` | RStudio project file; opening it sets the working directory to the repository root, as the R scripts expect. |

---

## Software environment

### Python

```bash
conda env create -f environment.yml
conda activate n2o-precision-fertilization
```

Notebook outputs are stripped from the repository, so the notebooks are stored without
figures or printed results; run them to reproduce the output. If you intend to commit
changes, install the filter that does the stripping:

```bash
pip install nbstripout
nbstripout --install
```

### R

The footprint scripts were run with R &#8805; 4.3 and require:

```r
install.packages(c("tidyverse", "openair", "ggpubr", "arrow", "fields", "lubridate",
                   "tibble", "purrr", "terra", "sf", "stringr", "readr"))
if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install("EBImage")   # required by the FFP climatology function
```

---

## Data availability

The code in this repository needs input data that are **not** part of the repository.
They are archived in the ETH Research Collection:

| Record | DOI | Content |
|--------|-----|---------|
| Input data of this analysis (`data_raw`) | [10.3929/ethz-c-000807633](https://doi.org/10.3929/ethz-c-000807633) | The files the notebooks and R scripts read, as documented in `data/raw/README.md`. |
| CH-TAN wheat 2023-24 flux product (full dataset) | [10.3929/ethz-c-000807457](https://doi.org/10.3929/ethz-c-000807457) | The complete eddy covariance flux product from which the half-hourly flux, meteo and management file used here is a subset. |

The processing chain behind the flux product is in a separate repository,
[dataset_ch-tan_wheat_2023-24_flux_product](https://github.com/fabioturc/dataset_ch-tan_wheat_2023-24_flux_product),
which is also archived on Zenodo.

**Access.** The records are under embargo until the associated article is published;
until then access is granted on request through the ETH Research Collection. Please
cite the records listed above when using the data.

---

## How to reproduce

1. Download the input data from the ETH Research Collection record
   [10.3929/ethz-c-000807633](https://doi.org/10.3929/ethz-c-000807633) and place the files directly in `data/raw/`,
   keeping the file names and the `GIS/` subfolder structure documented in
   `data/raw/README.md`.
2. Run the R scripts in `scripts/` in ascending numerical order, from the repository
   root, to produce the footprint climatologies.
3. Run the notebooks in `notebooks/` in ascending numerical order.

Working-directory convention:

* **R scripts** use paths relative to the **repository root** (open the `.Rproj` file).
* **Notebooks** use paths relative to the **`notebooks/` folder** (`../data/`, `../figures/`),
  i.e. they run as-is in Jupyter without changing directory.

---

## Shared plotting configuration

`notebooks/plot_config.py` holds the settings shared by all figures: treatment colours
and labels, the management events (sowing, fertilization dates and rates, harvest,
tillage) drawn as vertical lines, and the period definitions used throughout the
manuscript. Change it once and every figure follows.

---

## License

The code in this repository (`scripts/`, `notebooks/`) is released under the MIT
License; see `LICENSE`. The Kljun et al. (2015) FFP functions in `scripts/functions/`
are third-party code subject to their original terms. The data are not part of this
repository and are released under the terms stated in the ETH Research Collection
records (see *Data availability*). Citation metadata are in `CITATION.cff`.

---

## Contact

For questions about the code or the data, please open an issue in this repository or
contact the corresponding author (Fabio Turco).
