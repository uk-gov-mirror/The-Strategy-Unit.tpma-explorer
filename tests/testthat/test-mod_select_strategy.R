test_that("ui", {
  skip_if(interactive(), "This test will fail in interactive mode")

  setup_ui_test()

  ui <- mod_select_strategy_ui("test")

  expect_snapshot(ui)
})

test_that("selected_strategy returns input$strategy_select when rows are available", {
  # arrange
  fixture <- strategy_test_fixture()

  # act
  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = "Inpatients",
        strategy_mechanism_select = "Prevention",
        strategy_select = "Strategy B",
        strategy_subtype_select = "Sub-type 2"
      )
      session$private$flush()

      # assert
      expect_equal(selected_strategy(), "b")
    }
  )
})

test_that("strategies_filtered returns zero rows when nothing selected", {
  fixture <- strategy_test_fixture()

  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = character(0),
        strategy_mechanism_select = character(0)
      )
      session$private$flush()

      expect_equal(nrow(strategies_filtered()), 0)
    }
  )
})

test_that("it selects the restored value when it is valid", {
  # arrange
  fixture <- strategy_test_fixture()

  m_update <- mock()
  local_mocked_bindings("updateSelectInput" = m_update, .package = "shiny")

  m_restore <- mock("Strategy C") # a valid tpma_name for this selection
  local_mocked_bindings("restoreInput" = m_restore, .package = "shiny")

  # act
  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = "Inpatients",
        strategy_mechanism_select = character(0)
      )
      session$private$flush()

      # assert
      expect_called(m_update, 1)
      expect_args(
        m_update,
        1,
        inputId = "strategy_select",
        choices = list(
          "Inpatients: Prevention" = list("Strategy B"),
          "Inpatients: Redirection/Substitution" = list("Strategy A", "Strategy C")
        ),
        selected = "Strategy C" # the restored value, not the hardcoded default
      )
    }
  )
})

test_that("it selects the restored subtype value when it is valid", {
  # arrange
  fixture <- strategy_test_fixture()

  m_update <- mock()
  local_mocked_bindings(
    "updateSelectInput" = m_update,
    .package = "shiny"
  )

  m_restore <- mock(
    NULL,
    "Sub-type 1"
  )
  local_mocked_bindings(
    "restoreInput" = m_restore,
    .package = "shiny"
  )

  # act
  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = "Inpatients",
        strategy_mechanism_select = "Redirection/Substitution",
        strategy_select = "Strategy A"
      )
      session$private$flush()

      # assert
      expect_called(m_update, 2)

      expect_args(
        m_update,
        2,
        inputId = "strategy_subtype_select",
        choices = "Sub-type 1",
        selected = "Sub-type 1"
      )
    }
  )
})

test_that("it disables strategy_select and strategy_subtype_select and shows placeholders when no rows", {
  fixture <- strategy_test_fixture()

  m_update <- mock()
  m_disable <- mock()
  local_mocked_bindings("updateSelectInput" = m_update, .package = "shiny")
  local_mocked_bindings("disable" = m_disable, .package = "shinyjs")

  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = character(0),
        strategy_mechanism_select = character(0)
      )
      session$private$flush()

      expect_called(m_update, 2)
      expect_args(
        m_update,
        1,
        inputId = "strategy_select",
        choices = c("No TPMAs to show" = ""),
        selected = ""
      )
      expect_args(
        m_update,
        2,
        inputId = "strategy_subtype_select",
        choices = c("No TPMA sub-types to show" = ""),
        selected = ""
      )

      expect_called(m_disable, 2)
      expect_args(m_disable, 1, "strategy_select")
      expect_args(m_disable, 2, "strategy_subtype_select")
    }
  )
})

test_that("selected_strategy returns NULL when there are no matching rows", {
  # arrange
  fixture <- strategy_test_fixture()

  # act
  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = character(0),
        strategy_mechanism_select = character(0),
        strategy_select = "a" # even if this were somehow set, no rows means no valid strategy
      )
      session$private$flush()

      # assert
      expect_null(selected_strategy())
    }
  )
})
