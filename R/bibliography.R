extract_identifer <- function(x) {
  gsub("[[:space:]]", "", gsub(".+:", "", x))
}

detect_paper_type <- function(x) {
  ifelse(grepl("arxiv", x, ignore.case = TRUE),
         "arxiv",
         ifelse(grepl("doi", x, ignore.case = TRUE),
                "DOI",
                rlang::warn("Can't detect DOI or arXiv identifer")))
}
