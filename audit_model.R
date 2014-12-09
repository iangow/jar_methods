p_H <- 0.7
p_L <- 0.3
p_G <- 0.2
B <- 12
C_M <- 5
C_A <- 1
C_R <- 40

beta <- C_A /((p_H-p_L)*p_G*C_R)
p <- ((1 - p_G) * B - C_M)/( (1 - p_G) * B)
alpha <- ( p - p_L)/(p_H - p_L)
cat(alpha, beta, p)

p - (alpha * p_H + (1-alpha) * p_L)
(1 - p - (1-p) *p_G) * B - C_M
beta * (1-p_H) * p_G * C_R + C_A - beta * (1-p_L) * p_G * C_R

beta * (1-p) * p_G
(1-p)*(1-p_G)*B - C_M
# beta * (p_L-p_H) * p_G * C_R  + C_A
