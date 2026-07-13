#' Validate Strategy Selection
#' @param selected_strategy Reactive. Selected strategy variable name (or `NULL`).
#' @return A data.frame.
#' @noRD
validate_strategy_selected <- function(selected_strategy) {
  shiny::validate(
    shiny::need(
      !is.null(selected_strategy),
      "Choose a TPMA"
    )
  )
}
