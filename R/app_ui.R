#' Application User Interface
#' @param request Internal parameter for 'shiny'.
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    shinyjs::useShinyjs(),
    bslib::page_navbar(
      id = "page_navbar",
      title = "Explore opportunities to reduce hospital care",
      selected = "Explore data", # start with this panel open
      fillable = FALSE, # scrollable pages (i.e. don't fit cards to window extent)

      bslib::nav_panel(
        id = "nav_panel_overview",
        title = "Overview",
        icon = bsicons::bs_icon("grid"),
        mod_overview_ui("mod_overview")
      ),

      bslib::nav_panel(
        id = "nav_panel_viz",
        title = "Explore data",
        icon = bsicons::bs_icon("graph-up"),

        bslib::layout_sidebar(
          sidebar = bslib::sidebar(
            id = "sidebar",
            open = "open", # no longer needs to be toggled -- it only exists here
            width = 400,
            bslib::accordion(
              id = "sidebar_accordion",
              open = FALSE,
              multiple = TRUE,
              bslib::accordion_panel(
                title = "Choose a dataset",
                icon = bsicons::bs_icon("table"),
                mod_select_geography_ui("mod_select_geography"),
                mod_select_provider_ui("mod_select_provider")
              ),
              bslib::accordion_panel(
                title = "Choose a Type of Potentially-Mitigatable Activity (TPMA)",
                icon = bsicons::bs_icon("hospital"),
                mod_select_strategy_ui("mod_select_strategy")
              ),
              bslib::accordion_panel(
                title = "Bookmark",
                icon = bsicons::bs_icon("bookmark"),
                shiny::bookmarkButton(
                  label = "Generate shareable URL",
                  title = "Bookmark your selections and get a URL for sharing",
                  icon = NULL
                )
              )
            )
          ),
          mod_show_strategy_text_ui("mod_show_strategy_text"),
          mod_plot_rates_ui("mod_plot_rates"),
          bslib::layout_columns(
            col_widths = c(6, 6),
            mod_table_diagnoses_ui("mod_table_diagnoses"),
            mod_table_procedures_ui("mod_table_procedures")
          ),
          bslib::layout_columns(
            col_widths = c(6, 6),
            mod_plot_age_sex_pyramid_ui("mod_plot_age_sex_pyramid"),
            mod_plot_nee_ui("mod_plot_nee")
          )
        )
      ),

      bslib::nav_panel(
        id = "nav_panel_info",
        title = "About this tool",
        icon = bsicons::bs_icon("info-square"),

        bslib::layout_columns(
          col_widths = c(6, 6),
          fill = FALSE,
          bslib::layout_columns(
            col_widths = 12,
            fill = FALSE,
            bslib::card(
              id = "card_info_suggestions",
              bslib::card_header("Make suggestions"),
              md_file_to_html("app", "text", "info-suggestions.md")
            ),
            bslib::card(
              id = "card_info_data",
              bslib::card_header("Data"),
              md_file_to_html("app", "text", "info-data.md")
            ),
            bslib::card(
              id = "card_info_definitions",
              bslib::card_header("Definitions"),
              md_file_to_html("app", "text", "info-definitions.md")
            )
          ),
          bslib::layout_columns(
            col_widths = 12,
            fill = FALSE,
            bslib::card(
              id = "card_info_navigation",
              bslib::card_header("Navigate the app"),
              md_file_to_html("app", "text", "info-navigation.md")
            ),
            bslib::card(
              id = "card_info_interface",
              bslib::card_header("Adjust the app interface"),
              md_file_to_html("app", "text", "info-interface.md")
            ),
            bslib::card(
              id = "card_info_about",
              bslib::card_header("About the app"),
              md_file_to_html("app", "text", "info-about.md"),
              paste0(
                "Version ",
                as.character(utils::packageVersion(utils::packageName())),
                "."
              )
            )
          )
        )
      ),

      bslib::nav_spacer(), # pushes nav items below to the right
      bslib::nav_item(
        shiny::tags$a(
          href = Sys.getenv("FEEDBACK_FORM_URL"),
          target = "_blank",
          class = "nav-link",
          bsicons::bs_icon("chat-dots"),
          "Give feedback"
        )
      )
    )
  )
}
