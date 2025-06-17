#' trips: test H0: x-proportions = target proportions
#'
#' @param y direst total estimates => proportions y/sum(y) (target proportions)
#' @param se2 sampling variances of y 
#' @param x known proxy totals (e.g. by MNO)  
#'
#' @returns p-value of the ChiSquared test of equality
#' @export
#'
#' @examples
#' estimated counts from the survey
#' ysim = c(4962, 4795, 5139, 5273, 5417, 6649, 6493, 5550, 6582, 5861, 5816, 5927)
#' #
#' # estimated sampling errors for the y counts
#' sesim = c(405, 377, 549, 527, 438, 522, 494, 433, 633, 488, 483, 466)
#' #
#' # known counts
#' xsim = c(5404, 5144, 5693, 5776, 5895, 7703, 6839, 5757, 7483, 6242, 7420, 5588)
#' 
#' # run tests
#' audit.test(y = ysim, se2 = sesim^2, x = xsim)


audit.test <- function(y, se2, x)
{
    K = length(y)
    
    #idempotent transformation to remove non-zero means 
    pmat = diag(K) - outer(rep(1, K), rep(1, K))/K
    zmat = pmat %*% (y/x)
    
    #variance matrix of zmat  
    vmat = pmat %*% diag(se2/x^2) %*% pmat
    
    #standardise variance using Cholesky decomposition (lower-triangular)  
    lmat = solve(t(chol(vmat[-K, -K])))
    
    #test statistic  
    d = sum(c(lmat %*% zmat[-K,])^2)
    
    #test p-value by chisq-distribution  
    1 - pchisq(d, K-1)
}
