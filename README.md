
<!-- README.md is generated from README.Rmd. Please edit that file -->

# climatech

<!-- badges: start -->

<!-- badges: end -->

The goal of climatech is to make it easy to access and analyze data from
INTA weather stations, available through the Agricultural Information
and Management System (SIGA). With climatech you can download and read
data from any station using its ID, get a summary table of shelter
temperature for one or more stations, and plot its monthly average. The
package also includes example data so you can explore its functions
without downloading anything.It is a practice package developed as part
of a university course and is not intended for real-world use.

## Installation

You can install the development version of climatech from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("moravilar/climatech")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(climatech)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" alt="" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
