# Explore opportunities to reduce hospital care

<!-- badges: start -->
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Connect](https://img.shields.io/badge/Connect-Shiny-447099?style=flat&labelColor=white&logo=Posit&logoColor=447099)](https://connect.strategyunitwm.nhs.uk/tpma-explorer/)
[![R-CMD-check](https://github.com/The-Strategy-Unit/tpma-explorer/actions/workflows/check.yaml/badge.svg)](https://github.com/The-Strategy-Unit/tpma-explorer/actions/workflows/check.yaml)
[![Lint](https://github.com/The-Strategy-Unit/tpma-explorer/actions/workflows/check-jarl.yaml/badge.svg)](https://github.com/The-Strategy-Unit/tpma-explorer/actions/workflows/check-jarl.yaml)
[![codecov](https://codecov.io/gh/The-Strategy-Unit/tpma-explorer/branch/main/graph/badge.svg)](https://codecov.io/gh/The-Strategy-Unit/tpma-explorer)
<!-- badges: end -->

A web app to explore opportunities to reduce hospital care via Types of Potentially-Mitigatable Activity (TPMAs).

The app is [deployed openly to Posit Connect](https://connect.strategyunitwm.nhs.uk/tpma-explorer/) with no access requirements.
Developers can also access [a development version](https://connect.strategyunitwm.nhs.uk/tpma-explorer-dev/) of the app.

## For developers

This section is aimed at maintainers of the tool who work for The Strategy Unit Data Science team.

### Run and deploy

The app is made with [Shiny](https://shiny.posit.co/) and is an R package following [the nolem approach](https://github.com/StatsRhian/nolem).

To develop the app, you must:

1. Create an `.Renviron` file from the `.Renviron.example` template (restart R after making changes to this file).
2. Run `pak::pak()` to install required and developmental dependencies from the `DESCRIPTION`.
3. Run `app.R` to launch the app locally for development purposes.
4. Run `dev/deploy.R` to deploy the app to Posit Connect when ready (to 'dev' following pull-requests, to 'prod' for releases).

### Data

#### Location

Underlying data is generated via the NHP inputs-data pipeline in [the nhp_data repository](https://github.com/The-Strategy-Unit/nhp_data/) and is read into the app from the relevant Azure container (named in the `AZ_CONTAINER_INPUTS` environment variable).

#### Invalidation

Note that the inputs data is downloaded to the `app_data/` folder when you `run_app()`.

Locally, you can force-redownload the data by (a) deleting `app_data/` and re-sourcing `app.R`, or (b) by running  `get_all_data()` with the argument `redownload = TRUE`.

On the server, authorised devs can invalidate the current cache by appending `?reset_cache=true` to the apps' canonical URLs (i.e. `https://connect.strategyunitwm.nhs.uk/tpma-explorer` and `/tpma-explorer-dev`).
The data will be re-fetched the next time the app starts up.

### Files

In:

* `app_data/` you can find data downloaded from Azure (if `run_app()` has been run at least once)
* `data-raw/` you can can find code used to generate lookups in `inst/app/reference/`
* `dev/` you can find the `deploy.R` script to deploy to Posit Connect
* `inst/` you can find:
    * `golem-config.yaml`, which contains configuration (copied originally from [nhp_inputs](https://github.com/The-Strategy-Unit/nhp_inputs/blob/main/inst/golem-config.yml))
    * lookup data files in `app/reference/`
    * Markdown files under `app/text/`, which contain body and tooltip text
* `R/` you can find:
    * Shiny modules (server and UI components) that are stored in `mod_*.R` scripts
    * functions to help prepare data in `utils_*.R` scripts
    * logic for user facing outputs (plots, tables) in `fct_*.R` scripts
