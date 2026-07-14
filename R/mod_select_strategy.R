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
        md_file_to_html("app", "text", "sidebar-tooltip-activity.md")
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
      label = bslib::tooltip(
        trigger = list(
          "Filter by mechanism",
          bsicons::bs_icon("info-circle")
        ),
        md_file_to_html("app", "text", "sidebar-tooltip-mechanism.md")
      ),
      choices = c(
        "De-adoption",
        "Hospital Efficiency",
        "Prevention",
        "Redirection/Substitution"
      ),
      selected = "Hospital Efficiency"
    ),
    shiny::selectInput(
      ns("strategy_select"),
      label = bslib::tooltip(
        trigger = list("Choose a TPMA", bsicons::bs_icon("info-circle")),
        md_file_to_html("app", "text", "sidebar-tooltip-tpma.md")
      ),
      choices = NULL
    )
  )
}

#' Prepare Table of Options for Dropdown Menus
#'
#' Reads the remote TPMA lookup. Builds a 'full' TPMA name for the
#' TPMA-selection dropdown.
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
  strategies_lookup <- mod_select_strategy_get_strategies()

  shiny::moduleServer(id, function(input, output, session) {
    strategies_filtered <- shiny::reactive({
      # Checkbox-group handling is independent
      activity_selected <- length(input$strategy_activity_type_select) > 0
      mechanism_selected <- length(input$strategy_mechanism_select) > 0

      # Return empty data.frame (not NULL) to allow downstream handling
      if (!activity_selected && !mechanism_selected) {
        return(strategies_lookup[0, ])
      }

      if (activity_selected) {
        strategies_lookup <- strategies_lookup |>
          dplyr::filter(
            .data$activity_type %in% input$strategy_activity_type_select
          )
      }
      if (mechanism_selected) {
        strategies_lookup <- strategies_lookup |>
          dplyr::filter(
            .data$tpma_mechanism %in% input$strategy_mechanism_select
          )
      }

      strategies_lookup |> dplyr::arrange(.data$tpma_code)
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
