#' Out-of-bag (OOB) error for weighted least squares WLS 
#' and geographically weighted regression (GWR)
#'
#' @param data a matrix or dataframe with 7 columns: 
#' column names "y" should report the true counts in the grid cell (e.g. sensors)
#' column named "x" should report the proxy counts in the grid cell (e.g. MNO data)
#' columns named "c1" and "c2" report to the coordinates of y 
#' columns named "g1" and "g1"  the grid/tile index 
#' columns names "a1" and "a2" are the coordinates for x and are needed to calculate the distance
#' @param alpha parameter for adjusting weights by distance (range between ... and ...)
#' @param gamma parameter for for adjusting weights by variance (default 0, i.e. no adjustment)
#' @param disp logical, if TRUE (default) returns a graphical representation of the 
#' relative absolute error (RAE) for both WLS and GWR
#'
#' @returns estimates of RAE for both WLS and GWR (only for cells where there is a positive proxy count)
#' @export
#'
#' @examples
#' load example data (artificially generated)
#' load("sim.Rdata")
#' 
#' # estimation of RAE
#' oob.err(data = dta, alpha = 6, gamma = 0, disp = TRUE)
#' 
oob.err <- function(data, alpha = 6, gamma = 0, disp = TRUE)
{
    
    #data points with both (y,x)  
    idx = data[, "x"] > 0
    mat = as.matrix(data)
    
    y = mat[idx, "y"]
    z = mat[idx, "x"]
    x = mat[idx, c("a1", "a2")]/1000
    n = length(y)
    
    #matrix for storing OOB-errors: 1st column WLS, 2nd column GWR  
    oob = array(0, c(n, 2))
    colnames(oob) = c("wls", "gwr")
    
    # start loop
    for (j in 1:n) { 
        # OOB sample s  
        s = c(1:n)[-j]
    
        # prediciton by ratio regression without intercept, gamma = 0 if OLS   
        lfit = lm(y[s] ~ z[s] - 1, weight=(1/z[s])^gamma)
        oob[j,1] = z[j] * lfit$coef
        
        # standardised weights derived from Euclidean distances     
        d = sqrt(colSums((t(x[s, ]) - x[j, ])^2))
        w = 1/exp(alpha * d)
        w = w/sum(w)
        
        # OOB prediction by GWR    
        oob[j, 2] = z[j] * sum(w * z[s] * y[s])/sum(w * z[s]^2)
    }
    # end loop
    
    # relative absolute error (rae)
    rae = abs(oob - y)/y
    
    # grphical representation of errors
    if (disp) {
        gmat = mat[idx,c("g1", "g2")]
        par(mfrow = c(1, 2))
        par(pty = "s")
        
        # 1st plot: mRAE of WLS
        plot(0, xlim = c(0, 40), ylim =c(0, 40), bty = 'n',
             pch = '', ylab = '', xlab = '',
             main = paste("mrae(WLS)=", round(100 * mean(rae[ ,1])),"%", sep = ""))
        
        for (i in 1:n) { text(gmat[i, 1], gmat[i, 2],labels = round(100*rae[i, 1]), cex = 0.7) }
        
        # 2nd plot: mRAE of GWR
        plot(0, xlim = c(0, 40), ylim = c(0, 40), bty = 'n',
             pch = '', ylab = '', xlab = '',
             main = paste("mrae(GWR)=", round(100 * mean(rae[ ,2])),"%", sep = ""))
        for (i in 1:n) { text(gmat[i, 1], gmat[i,2], labels = round(100 * rae[i, 2]), cex = 0.7) }
    }
    rae
}

