#' Trips: estimation by Linear Prediction (LP) or transfer learning (TL) and their 
#' linear combination ('Mix')
#'
#' @param y direst total estimates => proportions y/sum(y) (target proportions)
#' @param se2 sampling variances of y 
#' @param x known proxy totals (e.g. by MNO)  
#'
#' @returns matrix with the various estimates (each column): py, px, pEBLUP, pTL. pMix 
#' @export
#'
#' @examples
#' # estimated counts from the survey
#' ysim = c(4962, 4795, 5139, 5273, 5417, 6649, 6493, 5550, 6582, 5861, 5816, 5927)
#' #
#' # estimated sampling errors for the y counts
#' sesim = c(405, 377, 549, 527, 438, 522, 494, 433, 633, 488, 483, 466)
#' #
#' # known counts
#' xsim = c(5404, 5144, 5693, 5776, 5895, 7703, 6839, 5757, 7483, 6242, 7420, 5588)
#' 
#' # obtain estimates
#' pest(y = ysim, se2 = sesim^2, x = xsim)

pest <- function(y, se2, x)
{
    K = length(y)
    
    #OLS of fixed effects under linear mixed model
    x1 = cbind(1, x)
    mu0 = c(x1 %*% c(solve(t(x1) %*% (x1)) %*% (t(x1) %*% y)))
    
    #variance of random effects by moment equation  
    a2 = (y - mu0)^2
    sv2 = max(0, sum(a2 - se2)/(K - 1))
    
    #EBLUP using estimated shrinkage factor => plp as estimated proportions   
    shr = sv2/(se2 + sv2)
    mu = c(x1 %*% c(solve(t(x1) %*% (x1/(se2 + sv2))) %*% (t(x1) %*% (y/(se2 + sv2)))))
    eblup = shr * y + (1 - shr)*mu
    plp = eblup/sum(eblup)
    
    #transfer learning given direst estimates phat and source proportions qhat    
    phat = y/sum(y)
    qhat = x/sum(x)
    
    #approximate variance of phat (NB. using qhat for smoothing)
    r = qhat
    w = array(r, c(K, K))
    diag(w) = 1 - r
    te2 = c((w^2 %*% se2)/sum(y)^2)
    
    #squared bias by moment equation  
    b2 = (phat - qhat)^2
    tu2 = max(0, mean(b2 - te2))
    
    #TL estimated proportions ptl  
    psi = tu2/(mean(te2) + tu2)
    ptl = psi * phat + (1 - psi) * qhat
    
    #robust mixing of LP and TL
    v0 = c(mean(a2)/sum(y)^2, mean(b2))
    pmx = plp * v0[2]/sum(v0) + ptl*v0[1]/sum(v0)
    
    #output all the estimates  
    cbind(py = phat, px = qhat, pEBLUP = plp, pTL = ptl, pMix = pmx)
}  
