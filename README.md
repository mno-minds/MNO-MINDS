R code for using Mobile Network Operator data in producing official
statistics
================
Last update: 20/06/2025

![](images/LogoMNO-MINDS.png)

This repository shares some of the R code developed within the MNO-MINDS
EU project framework. MNO-MINDS stands for “Mobile Network Operator
Methods for Integrating New Data Sources.” The Italian National
Institute of Statistics (Istat) is leading the project as coordinator,
along with nine other European national statistical institutes as
partners: Austria, Germany, Spain, France, the Netherlands, Norway,
Romania, Sweden, and Portugal.

The project started on November 1, 2023, and is expected to end on
November 30, 2025. The main goal is to identify new and existing
methodologies suitable for integrating Mobile Network Operator (MNO)
data with non-MNO data sources to produce regular official statistics.
The project’s official webpage can be found
[here](https://cros.ec.europa.eu/mno-minds).

The project activities are structured into four work-packages (WPs):

- [WP1 - coordination, management,
  dissemination;](https://cros.ec.europa.eu/book-page/mno-minds)

- [WP2 - landscaping analysis of possible non-MNO data sources to be
  integrated with MNO
  data;](https://cros.ec.europa.eu/book-page/mno-minds-wp2)

- [WP3 - development of methodologies and open-source tools for
  integrating MNO and non-MNO data
  sources; ](https://cros.ec.europa.eu/book-page/mno-minds-wp3)

- [WP4 - proof-of-concept of an ad-hoc survey to improve MNO
  data.](https://cros.ec.europa.eu/book-page/mno-minds-wp4)

<br>

<br>

In particular the WP3 worked to:

1.  Develop methodologies for processing and integrating MNO and non-MNO
    data according to a well-defined total error framework, considering
    different levels of data aggregation and data configuration and
    different uses of MNO data.

2.  Develop open-source code that implements methodologies not yet
    implemented in open-source tools.

The work on the software is documented in Deliverable D3.3, which will
be disseminated soon. This deliverable demonstrates that many of the
methodologies identified and employed in the application scenarios
outlined in Part III of Deliverable 3.2 have already been implemented in
open-source tools, particularly within the R environment (both base
functions and those in additional packages). However, some application
scenarios required the development of ad hoc code tailored to specific
data and applications. While this code is publicly available (see links
in Deliverable D3.3), it could not be generalized.

This repository contains a few R functions that implement relevant
methods for specific application scenarios. The first part of D 3.3
describes a tool that simulates real-world mobile network events and
provides artificial data for testing certain methods. The tool’s code
can be found [here](https://github.com/bogdanoancea/simulator). An
example of the generated data can be found in the
“[sim.RData](https://github.com/mno-minds/MNO-MINDS/tree/main/R_code_Sensor)”
dataset (R file format). This dataset is used in the “Sensor Presence”
case study. The R function
[`oob.err.R`](https://github.com/mno-minds/MNO-MINDS/blob/main/R_code_Sensor/oob.err.R)
was developed to apply the geographically weighted regression estimator
(expression 6.1 in D 3.2) and calculate the associated delete-one
out-of-bag prediction error.

``` r
# load artificial data
load("sim.RData")

# load code 
source("oob.err.R")

# run code
oob <- oob.err(data = dta, alpha = 6, 
               gamma = 0, disp = TRUE)
```

![](prova_Rearme_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

``` r
# show relative absolute error (rae)
head(oob)
```

    ##             wls         gwr
    ## [1,] 0.32662249 0.302865557
    ## [2,] 0.06847722 0.382204901
    ## [3,] 0.28791713 0.003341207
    ## [4,] 0.23042930 0.028278132
    ## [5,] 0.22129192 0.773076992
    ## [6,] 0.06847722 0.374025133

<br>

<br>

All of the analyses presented in Chapter 10 of Deliverable D3.2 were
conducted using the R environment (R Core Team, 2025). An ad hoc R
function,
[`audit.test.R`](https://github.com/mno-minds/MNO-MINDS/blob/main/R_code_trip_stats/audit.test.R),
was developed to apply the test described in Section 10.1. The R
function
[`pest.R`](https://github.com/mno-minds/MNO-MINDS/blob/main/R_code_trip_stats/pest.R)
implements the linear prediction, transfer-learning, and mixed ensemble
estimators described in Section 10.2 and illustrated in Section 10.3 of
D 3.2.

``` r
# estimated counts from the survey
ysim = c(4962, 4795, 5139, 5273, 5417, 6649, 
         6493, 5550, 6582, 5861, 5816, 5927)

# estimated sampling errors for the y counts
sesim = c(405, 377, 549, 527, 438, 522, 494, 
          433, 633, 488, 483, 466)

# known counts
xsim = c(5404, 5144, 5693, 5776, 5895, 7703, 
         6839, 5757, 7483, 6242, 7420, 5588)

# run tests
source("audit.test.R")
audit.test(y = ysim, se2 = sesim^2, x = xsim)
```

    ## [1] 0.6508766

<br>

<br>

All the analyses illustrated in Chapter 14 and included in deliverable D
3.2 were performed in the R environment (R Core Team, 2025), however,
they can be performed using any software package. The R function
[`sud.R`](https://github.com/mno-minds/MNO-MINDS/blob/main/R_code_QR_experiment/sud.R)
was developed to apply the SUD estimator (expression 8.6 in deliverable
D 3.2).

``` r
# device counts by contractor, 6 post strata
zsim = c(39, 761, 874, 793, 87, 14)

# measures derived from in-scope devices for the 6 post-strata
msim = c(140, 1798, 2018, 2007, 764, 398)

# known marginal distribution the 6 post-strata
wsim = c(0.073, 0.246, 0.242, 0.257, 0.112, 0.070)

# estimated device-mean to user-mean factor by user post-strata (6)
xisim = c(0.973, 0.978, 0.985, 0.982, 0.961, 0.842)

# estimated flow matrix of devices used by group-g and contracted by group-l (6 x 6)
 phisim = rbind(c(0.216, 0.002, 0.010, 0.005, 0.001, 0.000),
                c(0.042, 0.860, 0.060, 0.050, 0.013, 0.006),
                c(0.444, 0.062, 0.872, 0.054, 0.021, 0.012),
                c(0.290, 0.069, 0.048, 0.853, 0.072, 0.025),
                c(0.006, 0.006, 0.008, 0.033, 0.854, 0.065),
                c(0.002, 0.001, 0.002, 0.005, 0.039, 0.891))

## run the estimation
 source("sud.R")
sud(zstar = zsim, mstar = msim, W = wsim, 
    xi = xisim, phi = phisim)
```

    ## devest.tstar  sudest.that 
    ##    0.3389007    0.3448278
