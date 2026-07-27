strategy_test_fixture <- function() {
  tibble::tibble(
    tpma_code = c("AA-001", "AA-002", "EF-001", "AA-003"),
    tpma_name = c("Strategy A", "Strategy B", "Strategy C", "Strategy D"),
    tpma_subtype = NA_character_,
    tpma_name_full = c(
      "AA-001: Strategy A",
      "AA-002: Strategy B",
      "EF-001: Strategy C",
      "AA-003: Strategy D"
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
