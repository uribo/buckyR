#' Create issue template
#' @param user user account name
#' @param repo repository
#' @import rlang
#' @examples
#' \dontrun{
#' create_issue_template("uribo", "bucky_sandbox")
#' }
#' @export
create_issue_template <- function(user, repo) {
  path2issue_template <- ".github/ISSUE_TEMPLATE/paper_template.md"
  queries <- list(issue_template = list("data", "repository", "object"))
  ghq <-
    gh_graphql()
  ghq$cli$load_schema()
  ghq$qry$query("issue_template",
            glue::glue('
query{
  repository(owner: "<user>",name: "<repo>"){
    object(expression: "master:<path2issue_template>") {
      ... on Blob {
        text
      }
    }
  }
}',
                       .open = "<",
                       .close = ">"))

  is_issue_template_exist <-
    purrr::negate(
      ~ jsonlite::fromJSON(.x) %>%
        ## purrr::map_depth(3, ~ is.null(.x)) ... same
        purrr::pluck(!!! queries %>%
                       purrr::pluck("issue_template")) %>%
        is.null()
    )(ghq$cli$exec(ghq$qry$queries$issue_template))
  if (rlang::is_false(is_issue_template_exist)) {
    issue_template_base64 <-
      openssl::base64_encode("---
name: paper_template
about: Issue for papers.
title: 'DOI / arXiv: <identifier>'
labels: papers
assignees: ''

---

## Summary

## Description

### :flashlight: Highlights

### :game_die: Approach

### :hatching_chick: Results

### :speech_balloon: Comments")

    # openssl::base64_decode(issue_template_base64) %>%
    #   rawToChar() %>%
    #   cat()

    gh::gh("PUT /repos/:owner/:repo/contents/:path",
           owner = user,
           repo = repo,
           path = path2issue_template,
           message = "Added paper template",
           content = issue_template_base64)
  } else {
    rlang::inform(glue::glue("The issue template exists in the {user}/{repo} repository."))
  }
}
