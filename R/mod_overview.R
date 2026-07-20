#' Overview Page UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_overview_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::layout_columns(
    col_widths = c(3, 9),
    bslib::card(
      id = "card_overview_intro",
      bslib::card_header("Purpose"),
      md_file_to_html("app", "text", "overview-about.md")
    ),
    bslib::card(
      full_screen = TRUE,
      id = "card_overview_matrix",
      bslib::card_header("Types of Potentially-Mitigatable Activity (TPMAs) by mechanism"),
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
    dplyr::distinct(
      .data$tpma_name, # we're only showing the names, not the subtypes
      .data$activity_type,
      .data$tpma_mechanism
    ) |>
    dplyr::mutate(
      tpma_mechanism = factor(
        tpma_mechanism,
        levels = c(
          # 'Logical' ordering rather than alpha
          "Prevention",
          "De-adoption",
          "Redirection/Substitution",
          "Hospital Efficiency"
        )
      ),
      activity_type = dplyr::replace_values(
        .data$activity_type,
        # Takes up less space in the cards
        "Inpatients" ~ "IP",
        "Outpatients" ~ "OP"
      )
    )

  # Used in the mechanism header columns
  mechanism_descriptions <- c(
    "Prevention" = "Act upstream to improve people's health and manage their health risks",
    "De-adoption" = "Stop providing treatments that are unlikely to benefit patients",
    "Redirection/Substitution" = "Deliver care in the same or a different form in the community",
    "Hospital Efficiency" = "Improve the way we deliver care in hospital to reduce the time that patients spend there"
  )

  # Used to colour activity-type pills in each TPM< card
  type_palette <- c(
    # Matches what's in inst/app/text/overview-about.md
    "#ED8B00", # NHS orange (A&E)
    "#330072", # NHS purple (Inpatients)
    "#00A499" # NHS aqua green (Outpatients)
  )

  shiny::moduleServer(id, function(input, output, session) {
    output$overview_matrix <- shiny::renderUI({
      mechanisms <- tpma_lookup |>
        dplyr::arrange(.data$tpma_mechanism) |>
        dplyr::pull(.data$tpma_mechanism) |>
        unique()

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

          # One card per TPMA (shows name and coloured activity-type pill)
          tpma_cards <- rows_in_mechanism |>
            purrr::pmap(\(tpma_name, activity_type, tpma_mechanism) {
              col <- type_colours[[activity_type]]
              badge_style <- glue::glue(
                "background-color: {col}; color: white;"
              )

              bslib::card(
                class = "mb-0",
                full_screen = FALSE,
                bslib::card_body(
                  padding = "0.4rem", # tighter padding within card
                  shiny::div(
                    class = "d-flex justify-content-between align-items-start gap-3", # text/pill side-by-side
                    shiny::div(tpma_name),
                    shiny::span(
                      class = "badge rounded-pill flex-shrink-0", # pill stays sized to text
                      style = badge_style,
                      activity_type
                    )
                  )
                )
              )
            })

          # Mechanism column-header card: bold name/count with a description
          shiny::div(
            class = "d-flex flex-column gap-1", # vertical card gap
            bslib::card(
              class = "bg-light", # text-center to centre
              bslib::card_body(
                shiny::div(
                  class = "fw-bold",
                  glue::glue("{mechanism} ({nrow(rows_in_mechanism)})")
                ),
                shiny::div(
                  class = "small",
                  mechanism_descriptions[[mechanism]]
                )
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
