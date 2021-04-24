
<!-- README.md is generated from README.Rmd. Please edit that file -->

# buckyR

<!-- badges: start -->
<!-- badges: end -->

The goal of buckyR is to organize on scientific papers with R

## Installation

You can install the released version of buckyR from GitHub using remotes
package:

``` r
if (!requireNamespace("remotes"))
  install.packages("remotes")

remotes::install_github("uribo/buckyR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(buckyR)
## basic example code
```

**DOI**

``` r
make_issue_body("DOI: 10.1016/j.tourman.2019.104010")
```

```` markdown
```
## Information

:page_with_curl: Title: **Mobile phone network data reveal nationwide economic value of coastal tourism under climate change**
:busts_in_silhouette: Author: Takahiro Kubo and Shinya Uryu and Hiroya Yamano and Takahiro Tsuge and Takehisa Yamakita and Yoshihisa Shirayama
:link: URL: [https://doi.org/10.1016%2Fj.tourman.2019.104010](https://doi.org/10.1016%2Fj.tourman.2019.104010)
:date: April 2020 (Volume77)

### Article metrics

|cited_by_posts_count |cited_by_tweeters_count |cited_by_accounts_count |last_updated        |score |
|:--------------------|:-----------------------|:-----------------------|:-------------------|:-----|
|78                   |59                      |59                      |2020-03-11 09:00:57 |37.4  |

http://www.altmetric.com/details.php?citation_id=69031716
```
````

**arXiv**

``` r
make_issue_body("arXiv: 2104.07605")
```

```` markdown
```
## Information

:page_with_curl: Title: **SummVis: Interactive Visual Analysis of Models, Data, and Evaluation for
  Text Summarization**
:busts_in_silhouette: Author: Jesse Vig, Wojciech Kryscinski, Karan Goel, Nazneen Fatema Rajani
:link: URL: [http://arxiv.org/abs/2104.07605v1](http://arxiv.org/abs/2104.07605v1)
:date: Submitted: 2021-04-15 17:13:00 (Update: 2021-04-15 17:13:00)


### Abstract


```
  Novel neural architectures, training strategies, and the availability of
large-scale corpora haven been the driving force behind recent progress in
abstractive text summarization. However, due to the black-box nature of neural
models, uninformative evaluation metrics, and scarce tooling for model and data
analysis, the true performance and failure modes of summarization models remain
largely unknown. To address this limitation, we introduce SummVis, an
open-source tool for visualizing abstractive summaries that enables
fine-grained analysis of the models, data, and evaluation metrics associated
with text summarization. Through its lexical and semantic visualizations, the
tools offers an easy entry point for in-depth model prediction exploration
across important dimensions such as factual consistency or abstractiveness. The
tool together with several pre-computed model outputs is available at
https://github.com/robustness-gym/summvis.

```


### Article metrics

|cited_by_posts_count |cited_by_tweeters_count |cited_by_accounts_count |last_updated        |score |
|:--------------------|:-----------------------|:-----------------------|:-------------------|:-----|
|119                  |103                     |103                     |2021-04-23 15:55:04 |64.15 |

http://www.altmetric.com/details.php?citation_id=103991697
```
````
