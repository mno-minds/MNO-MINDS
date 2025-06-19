#' QR-estimation: SUD estimator by attributive post-stratification
#'
#' @param zstar in-scope device counts by contractor post-strata
#' @param mstar measures derived from in-scope devices, same contractor post-strata 
#' @param W known marginal distribution (rel. freq.) of post-strata (sum = 1)
#' @param xi estimated user-device factors by user post-strata; xi = 1 
#' (default) in the absence of device duplication
#' @param phi estimated flow matrix of devices used by group-g contracted by group-l
#      row for contractor, column for user, column sum = 1
#      phi = identity matrix in the absence of user ambiguity 
#'
#' @returns estimates
#' @export
#'
#' @examples
#' # device counts by contractor, 6 post strata
#' zsim = c(39, 761, 874, 793, 87, 14)
#' 
#' # measures derived from in-scope devices for the 6 post-strata
#' msim = c(140, 1798, 2018, 2007, 764, 398)
#' 
#' # known marginal distribution the 6 post-strata
#' wsim = c(0.073, 0.246, 0.242, 0.257, 0.112, 0.070)
#' 
#' # estimated device-mean to user-mean factor by user post-strata (6) 
#' xisim = c(0.973, 0.978, 0.985, 0.982, 0.961, 0.842)
#' 
#' # estimated flow matrix of devices used by group-g and contracted by group-l (6 x 6)
#'  phisim = rbind(c(0.216, 0.002, 0.010, 0.005, 0.001, 0.000),
#'                 c(0.042, 0.860, 0.060, 0.050, 0.013, 0.006),
#'                 c(0.444, 0.062, 0.872, 0.054, 0.021, 0.012),
#'                 c(0.290, 0.069, 0.048, 0.853, 0.072, 0.025),
#'                 c(0.006, 0.006, 0.008, 0.033, 0.854, 0.065),
#'                 c(0.002, 0.001, 0.002, 0.005, 0.039, 0.891))
#'  
#' ## run the estimation
#' sud(zstar = zsim, mstar = msim, W = wsim, xi = xisim, phi = phisim)

sud <- function(zstar, mstar, W, xi = 1, phi)
{
    # naive within-post-stratum device means  
    tstar = zstar/mstar 
    
    # estimated within-post-stratum user-device totals of interest
    zhat = solve(phi, zstar)
    zhat[zhat<0] = 0 
    
    # estimated within-post-stratum user-device counts
    mhat = solve(phi, mstar)
    mhat[mhat<0] = 0.001
    
    # estimated within-post-stratum user-device means  
    that = zhat/mhat
    
    # (naive, attributive) post-stratification estimate of population mean
    e = colSums(cbind(tstar,that) * xi * W)
    c(devest = e[1], sudest = e[2])
}


