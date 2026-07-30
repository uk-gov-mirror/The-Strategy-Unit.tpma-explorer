#' Select Strategy UI
#' @param id,input,output,session Internal parameters for `shiny`.
#' @noRd
mod_select_strategy_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::checkboxGroupInput(
      ns("strategy_activity_type_select"),
      label = shiny::div(
        class = "mb-2",
        bslib::tooltip(
          trigger = list(
            "Filter TPMAs by hospital setting:",
            bsicons::bs_icon("info-circle")
          ),
          shiny::div(
            style = "text-align: left;",
            shiny::div(
              style = "text-align: left;",
              md_file_to_html("app", "text", "sidebar-tooltip-activity.md")
            )
          )
        )
      ),
      choices = c(
        "A&E",
        "Inpatients",
        "Outpatients"
      ),
      selected = "Inpatients"
    ),
    shiny::checkboxGroupInput(
      ns("strategy_mechanism_select"),
      label = shiny::div(
        class = "mb-2",
        bslib::tooltip(
          trigger = list(
            "Filter TPMAs by mechanism:",
            bsicons::bs_icon("info-circle")
          ),
          shiny::div(
            style = "text-align: left;",
            md_file_to_html("app", "text", "sidebar-tooltip-mechanism.md")
          )
        )
      ),
      choices = c(
        "De-adoption",
        "Hospital Efficiency",
        "Prevention",
        "Redirection/Substitution"
      ),
      selected = "Redirection/Substitution"
    ),
    shiny::selectInput(
      ns("strategy_select"),
      label = shiny::div(
        class = "mb-2",
        bslib::tooltip(
          trigger = list(
            "Select a TPMA:",
            bsicons::bs_icon("info-circle")
          ),
          shiny::div(
            style = "text-align: left;",
            md_file_to_html("app", "text", "sidebar-tooltip-tpma.md")
          )
        )
      ),
      choices = NULL
    ),
    shiny::selectInput(
      ns("strategy_subtype_select"),
      label = shiny::div(
        class = "mb-2",
        bslib::tooltip(
          trigger = list(
            "Select a TPMA sub-type:",
            bsicons::bs_icon("info-circle")
          ),
          shiny::div(
            style = "text-align: left;",
            md_file_to_html("app", "text", "sidebar-tooltip-tpma-subtype.md")
          )
        )
      ),
      choices = NULL
    )
  )
}

#' Select Strategy Server
#' @param id Internal parameter for `shiny`.
#' @param tpma_lookup Data.frame. TPMA lookup read from GitHub.
#' @noRd
mod_select_strategy_server <- function(id, tpma_lookup) {
  shiny::moduleServer(id, function(input, output, session) {
    strategies_filtered <- shiny::reactive({
      # Checkbox-group handling is independent
      activity_selected <- length(input$strategy_activity_type_select) > 0
      mechanism_selected <- length(input$strategy_mechanism_select) > 0

      # Return empty data.frame (not NULL) to allow downstream handling
      if (!activity_selected && !mechanism_selected) {
        return(tpma_lookup[0, ])
      }

      if (activity_selected) {
        tpma_lookup <- tpma_lookup |>
          dplyr::filter(
            .data$activity_type %in% input$strategy_activity_type_select
          )
      }
      if (mechanism_selected) {
        tpma_lookup <- tpma_lookup |>
          dplyr::filter(
            .data$tpma_mechanism %in% input$strategy_mechanism_select
          )
      }

      tpma_lookup |> dplyr::arrange(.data$tpma_code)
    })

    shiny::observe({
      choices_df <- strategies_filtered() # can be empty

      if (nrow(choices_df) == 0) {
        # Providing a message means we must set a value. We set it as an empty
        # string and must handle this in downstream modules.
        shiny::updateSelectInput(
          inputId = "strategy_select",
          choices = c("No TPMAs to show" = ""), # requires empty-string value
          selected = ""
        )
        shinyjs::disable("strategy_select")
      } else {
        strategy_choices <- choices_df |>
          split(
            # To get dropdown section labels like 'Inpatients: De-adoption'
            list(
              choices_df$activity_type,
              choices_df$tpma_mechanism
            ),
            sep = ": ",
            drop = TRUE # remove non-viable permutations
          ) |>
          purrr::map(\(x) {
            x |>
              dplyr::select("tpma_name_full", "tpma_variable") |>
              tibble::deframe()
          })

        strategy_choices <- strategy_choices[sort(names(strategy_choices))]

        # Restore strategy value from bookmark, otherwise NULL
        restored_value <- shiny::restoreInput(
          id = session$ns("strategy_select"),
          default = NULL
        )

        # To help check if the restored value is valid
        valid_values <- unlist(strategy_choices, use.names = FALSE)

        selected_value <- if (
          !is.null(restored_value) &&
            restored_value %in% valid_values
        ) {
          restored_value
        } else {
          strategy_choices[[1]][[1]] # explicitly select first available
        }

        shiny::updateSelectInput(
          inputId = "strategy_select",
          choices = strategy_choices,
          selected = selected_value
        )
        shinyjs::enable("strategy_select")
      }
    }) |>
      shiny::bindEvent(
        input$strategy_activity_type_select,
        input$strategy_mechanism_select
      )

    selected_strategy <- shiny::reactive({
      # Depend on the filtered strategies as well as the select input
      choices_df <- strategies_filtered()

      # If there are no valid TPMAs, there is no selected strategy
      if (nrow(choices_df) == 0) {
        return(NULL)
      }

      input$strategy_select
    })

    selected_strategy
  })
}
