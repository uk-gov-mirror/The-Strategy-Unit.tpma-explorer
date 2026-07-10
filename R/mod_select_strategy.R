#' Select Strategy UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_select_strategy_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::checkboxGroupInput(
      ns("strategy_activity_type_select"),
      label = bslib::tooltip(
        trigger = list(
          "Filter by activity type",
          bsicons::bs_icon("info-circle")
        ),
        md_file_to_html("app", "text", "sidebar-tooltip-activity.md"),
      ),
      choices = c(
        "A&E",
        "Inpatients",
        "Outpatients"
      ),
      selected = "Inpatients"
    ),
    shiny::selectInput(
      ns("strategy_select"),
      label = bslib::tooltip(
        trigger = list("Choose a TPMA", bsicons::bs_icon("info-circle")),
        md_file_to_html("app", "text", "sidebar-tooltip-tpma.md"),
      ),
      choices = NULL
    )
  )
}

#' Prepare Table of Options for Dropdown Menus
#'
#' Reads the local mitigator-categories.csv and mitigators.json files. Extracts
#' names and categories into a single lookup table that can be filtered to help
#' decide what values to put in the dropdown menus.
#'
#' @return A data.frame.
#' @noRd
mod_select_strategy_get_strategies <- function() {
  # TODO: change path when merged to main
  readr::read_csv(
    "https://raw.githubusercontent.com/The-Strategy-Unit/TPMAs/refs/heads/10-lookup-update/reference/tpma-lookup.csv",
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

#' Select Strategy Server
#' @param id Internal parameter for `shiny`.
#' @noRd
mod_select_strategy_server <- function(id) {
  # load static data items
  strategies_lookup <- mod_select_strategy_get_strategies()

  # return the shiny module
  shiny::moduleServer(id, function(input, output, session) {
    strategies_filtered <- shiny::reactive({
      shiny::req(input$strategy_activity_type_select)

      strategies_lookup |>
        dplyr::filter(.data$activity_type %in% input$strategy_activity_type_select) |>
        dplyr::arrange(.data$tpma_code)
    })

    shiny::observe({
      strategy_choices <- strategies_filtered() |>
        split(
          # to get dropdown section labels like 'Inpatients: De-adoption'
          list(
            strategies_filtered()$activity_type,
            strategies_filtered()$tpma_mechanism
          ),
          sep = ": "
        ) |>
        purrr::map(\(x) {
          x |>
            dplyr::select("tpma_name_full", "tpma_variable") |>
            tibble::deframe()
        })

      strategy_choices <- strategy_choices[sort(names(strategy_choices))]

      shiny::updateSelectInput(
        session,
        "strategy_select",
        choices = strategy_choices,
        selected = NULL
      )
    }) |>
      shiny::bindEvent(input$strategy_activity_type_select)

    shiny::reactive(input$strategy_select)
  })
}
