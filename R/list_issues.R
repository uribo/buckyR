list_up_issues <- function(user, repo) {
  queries <- list(issue_count = list("data", "repository", "issues", "totalCount"),
                  collect_article_issue = list("data", "repository", "issues", "edges", "node"))
  ghq <-
    gh_graphql()
  ghq$cli$load_schema()

  ghq$qry$query("issue_count",
                glue::glue(
                  'query {
  repository(owner: "<user>", name: "<repo>") {
    issues {
      totalCount
    }
  }
}',
                  .open = "<",
                  .close = ">"
                ))

  issue_count <-
    ghq$cli$exec(ghq$qry$queries$issue_count) %>%
    jsonlite::fromJSON() %>%
    purrr::pluck(!!! queries %>%
                   purrr::pluck("issue_count"))

  ghq$qry$query("collect_article_issue",
                glue::glue(
                  'query {
  repository(owner: "<user>", name: "<repo>") {
    issues (labels: "papers", first: <issue_count>) {
      edges {
        node {
          title,
          number
        }
      }
    }
  }
}
',
.open = "<",
.close = ">"))

  ghq$cli$exec(ghq$qry$queries$collect_article_issue) %>%
    jsonlite::fromJSON() %>%
    purrr::pluck(!!! queries %>%
                   purrr::pluck("collect_article_issue"))
}
