#' GitHub graphql client
#' @param token github token
gh_graphql <- function(token = NULL) {
  if (is.null(token)) {
    token <-
      gh::gh_token()
  }
  list(
    qry = ghql::Query$new(),
    cli = ghql::GraphqlClient$new(
      url = "https://api.github.com/graphql",
      headers = list(Authorization = paste0("Bearer ", token)))
  )
}


