#' Journal name abbreviation
#' @param x journal name
#' @examples
#' abbr_journal_name("Proceedings of the National Academy of Sciences")
#' @export
abbr_journal_name <- function(x) {
  gsub(gsub("Journal", "J.",
            gsub("\\{", "",
                 gsub("}", "",
                      gsub("\\{\\\\", "", x)))),
       "Proceedings of the National Academy of Sciences", "PNAS")
}
