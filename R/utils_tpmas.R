#' Prepare Table of Options for Dropdown Menus
#'
#' Reads the remote TPMA lookup. Builds a 'full' TPMA name for the
#' TPMA-selection dropdown.
#'
#' @return A data.frame.
#' @noRd
fetch_tpma_lookup <- function() {
  readr::read_csv(
    "https://raw.githubusercontent.com/The-Strategy-Unit/TPMAs/refs/heads/main/reference/tpma-lookup.csv",
    col_types = "c"
  ) |>
    dplyr::filter(is.na(.data$active_to)) |>
    dplyr::mutate(
      tpma_name_full = dplyr::if_else(
        is.na(.data$tpma_subtype),
        glue::glue("{tpma_code}: {tpma_name}"),
        glue::glue("{tpma_code}: {tpma_name} ({tpma_subtype})")
      )
    ) |>
    dplyr::relocate(.data$tpma_name_full, .after = .data$tpma_subtype)
}
