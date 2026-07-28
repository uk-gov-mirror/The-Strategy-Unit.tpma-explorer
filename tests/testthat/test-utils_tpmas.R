test_that("fetch_tpma_lookup builds tpma_name_full correctly", {
  # arrange
  m_csv <- mock(
    tibble::tibble(
      tpma_code = c("IP-EF-001", "OP-EF-002"),
      tpma_name = c("Strategy A", "Strategy B"),
      tpma_subtype = c(NA, "Elective"),
      tpma_variable = c("a", "b"),
      activity_type = c("Inpatients", "Outpatients"),
      tpma_mechanism = c("Prevention", "De-adoption"),
      active_to = c(NA, NA)
    )
  )
  local_mocked_bindings("read_csv" = m_csv, .package = "readr")

  # act
  actual <- fetch_tpma_lookup()

  # assert
  expect_equal(
    actual$tpma_name_full,
    c("IP-EF-001: Strategy A", "OP-EF-002: Strategy B (Elective)")
  )
  expect_called(m_csv, 1)
})
