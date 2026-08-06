#' Run the Shiny Application
#' @export
run_app <- function() {
  download_all_data()

  shiny::addResourcePath(
    "www",
    app_sys("app/www")
  )

  options(
    # shinycssloaders options
    spinner.type = 1,
    spinner.color = "#f9bd07" # su-yellow
  )

  shiny::shinyApp(
    ui = app_ui,
    server = app_server,
    enableBookmarking = "server"
  )
}
