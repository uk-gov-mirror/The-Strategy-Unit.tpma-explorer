strategy_test_fixture <- function() {
  tibble::tibble(
    # Minimised fake data just for testing
    tpma_code = c("IP-EF-001", "IP-EF-002", "IP-EF-003", "OP-AA-001"),
    tpma_name = c("Strategy A", "Strategy B", "Strategy C", "Strategy D"),
    tpma_subtype = c("Sub-type 1", "Sub-type 2", NA_character_, NA_character_),
    tpma_name_full = c(
      "IP-EF-001: Strategy A (Sub-type 1)",
      "IP-EF-002: Strategy B (Sub-type 2)",
      "IP-EF-003: Strategy C",
      "OP-AA-001: Strategy D"
    ),
    tpma_variable = c("a", "b", "c", "d"),
    activity_type = c("Inpatients", "Inpatients", "Inpatients", "Outpatients"),
    tpma_mechanism = c(
      "Redirection/Substitution",
      "Prevention",
      "Redirection/Substitution",
      "Redirection/Substitution"
    ),
    active_to = NA_character_
  )
}
