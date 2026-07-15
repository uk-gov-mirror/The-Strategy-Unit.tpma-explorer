#' Select Provider UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_select_provider_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::selectInput(
    ns("provider_select"),
    label = bslib::tooltip(
      trigger = list(
        "Choose a statistical unit",
        bsicons::bs_icon("info-circle")
      ),
      md_file_to_html("app", "text", "sidebar-tooltip-provider.md"),
    ),
    choices = NULL
  )
}

#' Select Provider Server
#' @param id Internal parameter for `shiny`.
#' @param selected_geography Reactive. Selected geography, either `"nhp"` or
#'       `"la"`.
#' @noRd
mod_select_provider_server <- function(id, selected_geography) {
  shiny::moduleServer(id, function(input, output, session) {
    providers <- shiny::reactive({
      filename <- switch(
        selected_geography(),
        "la" = "la-datasets.json",
        "nhp" = "nhp-datasets.json"
      )

      shiny::req(filename)

      yyjsonr::read_json_file(app_sys("app", "reference", filename))
    }) |>
      shiny::bindEvent(selected_geography())

    shiny::observe({
      providers <- shiny::req(providers())
      provider_choices <- purrr::set_names(names(providers), providers)

      # Restore strategy value from bookmark, otherwise NULL
      restored_value <- shiny::restoreInput(
        id = session$ns("provider_select"),
        default = NULL
      )

      # To help check if the restored value is valid
      valid_values <- unname(provider_choices)

      selected_value <- if (!is.null(restored_value) && restored_value %in% valid_values) {
        restored_value
      } else {
        "E08000025" # Birmingham default, assumes default geography is "la"
      }

      shiny::updateSelectInput(
        session,
        "provider_select",
        choices = provider_choices,
        selected = selected_value
      )
    })

    shiny::reactive(input$provider_select)
  })
}
