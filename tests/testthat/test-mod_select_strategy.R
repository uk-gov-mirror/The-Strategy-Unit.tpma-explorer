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
        strategy_select = "b"
      )
      session$private$flush()

      # assert
      expect_equal(selected_strategy(), "b")
    }
  )
})

test_that("strategies_filtered filters by activity_type and mechanism", {
  # arrange
  fixture <- strategy_test_fixture()

  # act
  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      # act 1
      session$setInputs(
        strategy_activity_type_select = "Inpatients",
        strategy_mechanism_select = character(0)
      )
      session$private$flush()

      # assert 1
      expect_equal(
        strategies_filtered()$tpma_code,
        c("IP-EF-001", "IP-EF-002", "IP-EF-003")
      )

      # act 2
      session$setInputs(
        strategy_activity_type_select = "Inpatients",
        strategy_mechanism_select = "Redirection/Substitution"
      )
      session$private$flush()

      # assert 2
      expect_equal(
        strategies_filtered()$tpma_code,
        c("IP-EF-001", "IP-EF-003")
      )
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

  m_restore <- mock("c") # 'c' is a valid tpma_variable for this selection
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
          "Inpatients: Prevention" = c("IP-EF-002: Strategy B" = "b"),
          "Inpatients: Redirection/Substitution" = c(
            "IP-EF-001: Strategy A" = "a",
            "IP-EF-003: Strategy C" = "c"
          )
        ),
        selected = 'c' # the restored value, not the first available ("b")
      )
    }
  )
})

test_that("it disables strategy_select and shows placeholder when no rows", {
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

      expect_called(m_update, 1)
      expect_args(
        m_update,
        1,
        inputId = "strategy_select",
        choices = c("No TPMAs to show" = ""),
        selected = ""
      )
      expect_called(m_disable, 1)
      expect_args(m_disable, 1, "strategy_select")
    }
  )
})

test_that("it updates strategy_select choices when rows are available", {
  fixture <- strategy_test_fixture()

  m_update <- mock()
  local_mocked_bindings("updateSelectInput" = m_update, .package = "shiny")

  shiny::testServer(
    mod_select_strategy_server,
    args = list(tpma_lookup = fixture),
    {
      session$setInputs(
        strategy_activity_type_select = "Outpatients",
        strategy_mechanism_select = "Redirection/Substitution"
      )
      session$private$flush()

      expect_called(m_update, 1)
      expect_args(
        m_update,
        1,
        inputId = "strategy_select",
        choices = list(
          "Outpatients: Redirection/Substitution" = c("OP-AA-001: Strategy D" = "d")
        ),
        selected = "d"
      )
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
