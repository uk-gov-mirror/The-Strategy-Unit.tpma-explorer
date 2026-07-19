#' Overview Page UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_overview_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_columns(
    col_widths = c(3, 9),
    bslib::card(
      id = "card_overview_intro",
      bslib::card_header("About TPMAs"),
      md_file_to_html("app", "text", "overview-about.md")
    ),
    bslib::card(
      full_screen = TRUE,
      id = "card_overview_matrix",
      bslib::card_header("TPMAs by mechanism"),
      shinycssloaders::withSpinner(shiny::uiOutput(ns("overview_matrix")))
    )
  )
}

#' Overview Page Server
#' @param id Internal parameter for `shiny`.
#' @param tpma_lookup Data.frame. TPMA lookup read from GitHub.
#' @noRd
mod_overview_server <- function(id, tpma_lookup) {
  tpma_lookup <- tpma_lookup |>
    dplyr::distinct(.data$tpma_name, .data$activity_type, .data$tpma_mechanism)

  type_palette <- c(
    # Matches what's in inst/app/text/overview-about.md
    "#330072", # NHS purple (A&E)
    "#00A499", # NHS aqua green (Inpatients)
    "#ED8B00" # NHS orange (Outpatients)
  )

  shiny::moduleServer(id, function(input, output, session) {
    output$overview_matrix <- shiny::renderUI({
      mechanisms <- tpma_lookup |>
        dplyr::pull(.data$tpma_mechanism) |>
        unique() |>
        sort()

      activity_types <- tpma_lookup |>
        dplyr::pull(.data$activity_type) |>
        unique() |>
        sort()

      type_colours <- type_palette |>
        rep_len(length(activity_types)) |>
        purrr::set_names(activity_types)

      columns <- mechanisms |>
        purrr::map(\(mechanism) {
          rows_in_mechanism <- tpma_lookup |>
            dplyr::filter(.data$tpma_mechanism == mechanism)

          # One card per TPMA in this mechanism: a small coloured pill
          # identifies the activity_type, tpma_name follows below it.
          tpma_cards <- rows_in_mechanism |>
            purrr::pmap(\(tpma_name, activity_type, tpma_mechanism) {
              col <- type_colours[[activity_type]]
              badge_style <- glue::glue(
                "background-color: {col}; color: white;"
              )

              bslib::card(
                full_screen = FALSE,
                bslib::card_body(
                  gap = 10, # between pill and body text
                  shiny::span(
                    class = "badge rounded-pill align-self-start", # pill wide as text
                    style = badge_style,
                    activity_type
                  ),
                  shiny::div(tpma_name)
                )
              )
            })

          # Mechanism header card, with a count of how many TPMAs fall
          # under it, stacked above its TPMA cards.
          shiny::div(
            class = "d-flex flex-column",
            bslib::card(
              class = "bg-light fw-bold text-center",
              bslib::card_body(
                glue::glue("{mechanism} ({nrow(rows_in_mechanism)})")
              )
            ),
            tpma_cards
          )
        })

      shiny::tagList(
        do.call(bslib::layout_columns, columns)
      )
    })
  })
}
