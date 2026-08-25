test_that("ui", {
  skip_if(interactive(), "This test will fail in interactive mode")

  setup_ui_test()

  ui <- mod_show_strategy_text_ui("test")

  expect_snapshot(ui)
})

test_that("mod_show_strategy_text_get_descriptions_lookup", {
  # arrange

  # act
  lookup <- mod_show_strategy_text_get_descriptions_lookup()

  # assert
  expect_s3_class(lookup, "data.frame")
  expect_true(all(
    c("tpma_variable", "tpma_description_name") %in% names(lookup)
  ))
})

test_that("strategy_stub", {
  # arrange
  local_mocked_bindings(
    "mod_show_strategy_text_get_descriptions_lookup" = \() {
      tibble::tibble(
        tpma_variable = c(
          "strategy_a_acute",
          "strategy_a_chronic",
          "strategy_b"
        ),
        tpma_description_name = c(
          "strategy_a",
          "strategy_a",
          "strategy_b"
        )
      )
    }
  )

  # act
  shiny::testServer(
    mod_show_strategy_text_server,
    args = list(selected_strategy = reactiveVal("a")),
    {
      # assert
      selected_strategy("strategy_a_acute")
      actual1 <- strategy_stub()

      selected_strategy("strategy_a_chronic")
      actual2 <- strategy_stub()

      selected_strategy("strategy_b")
      actual3 <- strategy_stub()

      expect_equal(actual1, "strategy_a")
      expect_equal(actual2, "strategy_a")
      expect_equal(actual3, "strategy_b")
    }
  )
})

test_that("strategy_text", {
  # arrange
  m <- mock("text_a", "text_b", "text_a")
  local_mocked_bindings(
    mod_show_strategy_text_get_descriptions_lookup = function() {
      tibble::tibble(
        tpma_variable = c(
          "strategy_a_acute",
          "strategy_a_chronic",
          "strategy_b"
        ),
        tpma_description_name = c(
          "strategy_a",
          "strategy_a",
          "strategy_b"
        )
      )
    },
    read_strategy_text = m
  )

  # act
  shiny::testServer(
    mod_show_strategy_text_server,
    args = list(selected_strategy = reactiveVal("a")),
    {
      # act
      selected_strategy("strategy_a_acute")
      actual1 <- strategy_text()

      selected_strategy("strategy_b")
      actual2 <- strategy_text()

      selected_strategy("strategy_a_chronic")
      actual3 <- strategy_text()

      # assert
      expect_equal(actual1, "text_a")
      expect_equal(actual2, "text_b")
      expect_equal(actual3, "text_a")

      expect_called(m, 3)
      expect_args(m, 1, "strategy_a")
      expect_args(m, 2, "strategy_b")
      expect_args(m, 3, "strategy_a")
    }
  )
})

test_that("strategy_text is rendered", {
  # arrange
  fixture <- strategy_test_fixture()
  m <- mock("html")

  local_mocked_bindings(
    mod_show_strategy_text_get_descriptions_lookup = function() {
      tibble::tibble(
        tpma_variable = c(
          "strategy_a_acute",
          "strategy_a_chronic",
          "strategy_b"
        ),
        tpma_description_name = c(
          "strategy_a",
          "strategy_a",
          "strategy_b"
        )
      )
    },
    read_strategy_text = function(...) "strategy text",
    md_string_to_html = m,
    validate_strategy_selected = function(...) NULL
  )

  # act
  shiny::testServer(
    mod_show_strategy_text_server,
    args = list(
      selected_strategy = reactiveVal("strategy_a_acute"),
      tpma_lookup = fixture
    ),
    {
      actual <- output$strategy_text

      # assert
      expect_equal(actual, "html")

      expect_called(m, 1)
      expect_args(
        m,
        1,
        "strategy text"
      )
    }
  )
})
