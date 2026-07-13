#' Show Strategy Description UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_show_strategy_text_ui <- function(id) {
  ns <- shiny::NS(id)
  bslib::card(
    bslib::card_header("Description"),
    bslib::card_body(
      shinycssloaders::withSpinner(
        shiny::htmlOutput(ns("strategy_text"))
      )
    )
  )
}

#' Get Strategy descriptions Lookup
#' @return a character vector of the strategy stubs.
#' @noRd
mod_show_strategy_text_get_descriptions_lookup <- function() {
  # TODO: move this into the TPMAs repo? See:
  # https://github.com/The-Strategy-Unit/TPMAs/issues/16
  readr::read_csv(
    app_sys("app", "reference", "tpma-description-lookup.csv"),
    col_types = "c"
  )
}

#' Show Strategy Description Server
#' @param id Internal parameter for `shiny`.
#' @noRd
mod_show_strategy_text_server <- function(
  id,
  selected_strategy
) {
  descriptions_lookup <- mod_show_strategy_text_get_descriptions_lookup()

  # return the shiny module
  shiny::moduleServer(id, function(input, output, session) {
    strategy_stub <- shiny::reactive({
      strategy <- shiny::req(selected_strategy())

      descriptions_lookup |>
        dplyr::filter(tpma_variable == strategy) |>
        dplyr::pull(tpma_description_name)
    })

    strategy_text <- shiny::reactive({
      s <- shiny::req(strategy_stub())
      read_strategy_text(s)
    })

    output$strategy_text <- shiny::renderText({
      validate_strategy_selected(selected_strategy())

      t <- shiny::req(strategy_text())
      md_string_to_html(t)
    })
  })
}
