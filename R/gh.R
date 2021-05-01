make_issue_info <- function(target_article_parsed, type) {
  if (type == "arxiv") {
    glue::glue(
        "## Information\n
:page_with_curl: Title: **{title}**
:busts_in_silhouette: Author: {author}
:link: URL: [{url}]({url})
:date: Submitted: {submit_time} (Update: {update_time})\n

### Abstract\n
```
{abstract}
```",
        title = target_article_parsed$title,
        author = target_article_parsed$author,
        url = target_article_parsed$url,
        abstract = target_article_parsed$abstract,
        submit_time = as.POSIXct(target_article_parsed$submitted, tz = "UTC"),
        update_time = as.POSIXct(target_article_parsed$updated, tz = "UTC"))
  } else if (type == "DOI") {
    glue::glue(
      "## Information\n
      :page_with_curl: Title: **{title}**
      :busts_in_silhouette: Author: {author}
      :link: URL: [{url}]({url})
      :date: {month} {year} (Volume{volume}{number})
      ",
      title = target_article_parsed$title,
      author = target_article_parsed$author,
      url = target_article_parsed$url,
      year = target_article_parsed$year,
      month = month.name[which(grepl(target_article_parsed$month, month.abb, ignore.case = TRUE))],
      volume = ifelse(is.null(target_article_parsed$volume),
                      "",
                      target_article_parsed$volume),
      number = ifelse(is.null(target_article_parsed$number), "",
                      paste0(" #&#x2060;", target_article_parsed$number)))
  }
}

identific_altmetrics <- function(type = NULL, identifer = NULL) {
  args <-
    list(doi = ifelse(type == "DOI", identifer, NA),
         arxiv = ifelse(type == "arxiv", identifer, NA)) %>%
    purrr::keep(~ !is.na(.x))
  res_altm <-
    rlang::exec(rAltmetric::altmetrics, !!!args)
  df_res_altm <-
    rAltmetric::altmetric_data(res_altm)
  vars_altm <-
    names(df_res_altm)[names(df_res_altm) %in% c(
      "cited_by_posts_count",
      "cited_by_tweeters_count",
      "cited_by_accounts_count",
      "score",
      "last_updated")]
  df_res_altm <-
    df_res_altm[, vars_altm]
  df_res_altm$last_updated <-
    as.POSIXct(as.numeric(df_res_altm$last_updated),
               origin = "1970-01-01 00:00:00",
               tz = "UTC")
  altmetric_score <-
    df_res_altm %>%
    knitr::kable() %>%
    as.character() %>%
    paste(collapse = "\n")
  altmetric_url <-
    res_altm$details_url
  list(score = altmetric_score, url = altmetric_url)
}

make_issue_metrics <- function(issue_body, type, identifer) {
  res_altm <-
    identific_altmetrics(type = type, identifer = identifer)
  glue::glue(
    issue_body,
    "\n\n",
    glue::glue(
      '### Article metrics\n
    {score}\n
    {url}',
      score = res_altm$score,
      url = res_altm$url))
}

#' Make GitHub issue's body contents
#' @param x GitHub issue title
#' @inheritParams rcrossref::cr_cn
#' @param ... path to [rcrossref::cr_cn][rcrossref::cr_cn]
#' @rdname make_issue_body
#' @examples
#' \dontrun{
#' make_issue_body("DOI: 10.1016/j.tourman.2019.104010")
#' make_issue_body("arXiv: 2104.07605")
#' }
#' @export
make_issue_body <- function(x, style = "oikos", ...) {
  paper_type <-
    detect_paper_type(x)
  paper_identifer <-
    extract_identifer(x)
  if (paper_type == "arxiv") {
    target_article <-
      aRxiv::arxiv_search(id_list = paper_identifer,
                          sep = ", ",
                          limit = 1)
    target_article_parsed <-
      list(author = target_article$authors,
           title = target_article$title,
           url = target_article$link_abstract,
           submitted = target_article$submitted,
           year = substr(target_article$submitted, 1, 4),
           updated = target_article$updated,
           abstract = target_article$abstract)
  } else if (paper_type == "DOI") {
    target_article_parsed <-
      rcrossref::cr_cn(dois = paper_identifer,
                       style = style,
                       ...) %>%
      rcrossref:::parse_bibtex()
  }
  if (is.null(target_article_parsed)) {
    list(title = NULL,
         labels = NULL,
         body = NULL)
  } else {
    if (paper_type == "arxiv") {
      issue_labels <-
        list(paste("Journal:", "arXiv"),
             paste("Published year:", target_article_parsed$year),
             paste("Category:", target_article$primary_category))
    } else if (paper_type == "DOI") {
      issue_labels <-
        list(paste("Journal:", abbr_journal_name(target_article_parsed$journal)),
             paste("Published year:", target_article_parsed$year),
             paste("Type:", target_article_parsed$entry))
    }
    issue_title <-
      paste(
        paste(
          gsub(pattern = "[[:space:]].+", "", target_article_parsed$author),
          target_article_parsed$year,
          sep = "_"
        ),
        target_article_parsed$title,
        sep = ": ")
    issue_body <-
      make_issue_info(target_article_parsed, type = paper_type) %>%
      make_issue_metrics(type = paper_type,
                         identifer = paper_identifer)
    list(title = issue_title,
         labels = issue_labels,
         body = issue_body)
  }
}

check_duplicate <- function(x, issue_list, close = FALSE, user, repo, number) {
  title <- NULL
  duplicate_num <-
    subset(issue_list, title == x) %>%
    purrr::pluck("number")
  if (rlang::is_false(is.null(duplicate_num)) & rlang::is_true(close)) {
    gh::gh("PATCH /repos/:owner/:repo/issues/:number",
           owner = user,
           repo = repo,
           number = number,
           body = glue::glue("Duplicate #{duplicate_num}"),
           labels = list("duplicate"),
           state = "closed")
  }
  duplicate_num
}

#' Update article information
#' @param x x
#' @param number issue number
#' @param labels issue labels
#' @inheritParams create_issue_template
#' @import rlang
#' @export
article_info <- function(x, user, repo, number, labels = NULL) {
  if (!is.null(labels)) {
    current_labels <- labels
  } else {
    current_labels <- c(`papers` = "papers")
  }
  gen_body <-
    make_issue_body(x = x)
  # Check duplicate ---------------------------------------------------------
  duplicate_num <-
    check_duplicate(x = gen_body$title,
                    issue_list = list_up_issues(user, repo),
                    user = user,
                    repo = repo,
                    number = number,
                    close = TRUE)
  # Added article information -----------------------------------------------
  if (!is.null(gen_body$body) & is.null(duplicate_num)) {

  # Modified issue title and assigned label ---------------------------------
  issue_labels <-
    purrr::list_modify(gen_body$labels,
                       !!!as.list(current_labels) %>%
                         purrr::set_names(current_labels)) %>%
    purrr::set_names(NULL) %>%
    purrr::keep(~ nchar(.x) <= 50)

  gh::gh("PATCH /repos/:owner/:repo/issues/:number",
         owner = user,
         repo = repo,
         number = number,
         title = gen_body$title,
         labels = issue_labels)
  gh::gh("POST /repos/:owner/:repo/issues/:number/comments",
         owner = user,
         repo = repo,
         number = number,
         body = gen_body$body)
  }
}
