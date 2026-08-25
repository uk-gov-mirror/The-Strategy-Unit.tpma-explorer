setup_app_server_tests <- function(.env = parent.frame()) {
  tpma_lookup_fixture <- tibble::tibble(
    tpma_code = c("AA-001", "AA-002"),
    tpma_name = c("Example TPMA one", "Example TPMA two"),
    tpma_subtype = c("Sub-type one", NA_character_),
    tpma_name_full = c("AA-001: Example TPMA one (Sub-type one)", "AA-002: Example TPMA two"),
    tpma_variable = c("strategy_1", "strategy_2"),
    activity_type = c("Inpatients", "A&E"),
    tpma_mechanism = c("Prevention", "Redirection/Substitution"),
    active_to = NA_character_
  )

  mocks <- list(
    fetch_tpma_lookup = mockery::mock(tpma_lookup_fixture),
    mod_select_geography_server = mockery::mock(shiny::reactiveVal("nhp")),
    mod_select_provider_server = mockery::mock(shiny::reactiveVal("ABC")),
    mod_select_strategy_server = mockery::mock(shiny::reactiveVal("strategy")),
    mod_show_strategy_text_server = mockery::mock(),
    mod_plot_rates_server = mockery::mock(),
    mod_table_procedures_server = mockery::mock(),
    mod_table_diagnoses_server = mockery::mock(),
    mod_plot_age_sex_pyramid_server = mockery::mock(),
    mod_plot_nee_server = mockery::mock()
  )

  do.call(testthat::local_mocked_bindings, c(mocks, .env = .env))

  dplyr::lst(mocks, tpma_lookup_fixture)
}
