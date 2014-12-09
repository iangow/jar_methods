mmult <- function(p_temp, v) {
    m <- dim(p_temp)[1]
    k <- dim(v)[2]
    
    val <- matrix(nrow=m, ncol=k)
    
    for(i in 1:m) {
        for (j in 1:k) {  
            val[i,j] <- p_temp[i, ] %*% ifelse(p_temp[i, ]!=0, v[,j], 0)
        }
    }
    return(val)
}

# Matching Demonstration 1
p <- matrix(c(0.36, 0.12, 0.12, 0.08, 0.12, 0.2), nrow = 3)
Y <- matrix(c(2, 6, 10, 4, 8, 14), nrow = 3)

p_D <- rep(1, dim(p)[1]) %*% matrix(colSums(p), nrow = 1)
t(p / p_D) %*% Y
est <- mmult(t(p / p_D), Y)
te <- est[,2, drop=FALSE]-est[,1, drop=FALSE]
cat("ATC:", te[1])
cat("ATT:", te[2])
cat("ATE:",  colSums(p) %*% te)

# Matching Demonstration 2
p <- matrix(c(0.4, 0.1, 0.1, 0.00, 0.13, 0.27), nrow = 3)
Y <- matrix(c(2, 6, 10, NA, 8, 14), nrow = 3)

p_D <- rep(1, dim(p)[1]) %*% matrix(colSums(p), nrow = 1)
t(p / p_D) %*% ifelse(!is.na(Y), Y, 0)

est <- mmult(t(p / p_D), Y)
te <- est[,2, drop=FALSE]-est[,1, drop=FALSE]
cat("ATC:", te[1])
cat("ATT:", te[2])
cat("ATE:",  colSums(p) %*% te)

