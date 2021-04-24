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
           updated = target_article$updated,
           abstract = target_article$abstract)
  } else if (paper_type == "DOI") {
    target_article_parsed <-
      rcrossref::cr_cn(dois = paper_identifer,
                       style = style,
                       ...) %>%
      rcrossref:::parse_bibtex()
  }
  if (is.null(target_article)) {
    NULL
  } else {
    make_issue_info(target_article_parsed, type = paper_type) %>%
      make_issue_metrics(type = paper_type,
                         identifer = paper_identifer)
  }
}
