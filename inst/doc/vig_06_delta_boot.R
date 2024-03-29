## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
## knitr configuration: http://yihui.name/knitr/options#chunk_options
library(knitr)
showMessage <- FALSE
showWarning <- TRUE
set_alias(w = "fig.width", h = "fig.height", res = "results")
opts_chunk$set(comment = "##", error= TRUE, warning = showWarning, message = showMessage,
               tidy = FALSE, cache = FALSE, echo = TRUE,
               fig.width = 7, fig.height = 7,
               fig.path = "man/figures")

## -----------------------------------------------------------------------------
library(regmedint)
library(tidyverse)

expit <- function(x){exp(x)/(1 + exp(x))}

## -----------------------------------------------------------------------------
library(parallel)
library(MASS)
numCores <- detectCores()
numCores

## -----------------------------------------------------------------------------
# Number of bootstrap
trials <- 1:5000
seed <-  3104

## -----------------------------------------------------------------------------
# Model 1: M linear, Y linear
datamaker.s4.m1 <- function(n, k){
  C <- matrix(rnorm(n*1, 0, 2), ncol = 1)
  A <- rbinom(n, 1, expit(C + C^2))
  M <- 0.2 + 0.4*A + 0.5*C + 0.2*A*C + rnorm(n, 0, 0.5)
  Y <- 0.5 + 0.3*A + 0.2*M + 0.5*A*M + 0.2*A*C + k*M*C + rnorm(n, 0, 0.5)
  list(C = C, A = A, M = M, Y = Y)
}

# Model 2: M logistic, Y linear
datamaker.s4.m2 <- function(n, k){
  C <- matrix(rnorm(n*1, 0, 2), ncol = 1)
  A <- rbinom(n, 1, expit(C + C^2))
  M <- rbinom(n, 1, expit(0.2 + 0.4*A + 0.5*C + 0.2*A*C))
  Y <- 0.5 + 0.3*A + 0.2*M + 0.5*A*M + 0.2*A*C + k*M*C + rnorm(n, 0, 0.5)
  list(C = C, A = A, M = M, Y = Y)
}

# Model 3: M linear, Y logistic
datamaker.s4.m3 <- function(n, k){
  C <- matrix(rnorm(n*1, 0, 2), ncol = 1)
  A <- rbinom(n, 1, expit(C + C^2))
  M <- (0.2 + 0.4*A + 0.5*C + 0.2*A*C + rnorm(n, 0, 0.5)/5)
  Y <- rbinom(n, 1, expit((0.5 + 0.3*A + 0.6*M + 0.4*C + 0.5*A*M + 0.2*A*C + k*M*C)))
  list(C = C, A = A, M = M, Y = Y)
}

# Model 4: M logistic, Y logistic
datamaker.s4.m4 <- function(n, k){
  C <- matrix(rnorm(n*1, 0, 2), ncol = 1)
  A <- rbinom(n, 1, expit(C + C^2))
  M <- rbinom(n, 1, expit(0.2 + 0.4*A + 0.5*C + 0.2*A*C))
  Y <- rbinom(n, 1, expit(0.5 + 0.3*A + 0.2*M + 0.1*C + 0.5*A*M + 0.2*A*C + k*M*C))
  list(C = C, A = A, M = M, Y = Y)
}

## -----------------------------------------------------------------------------
set.seed(seed)
dat_linear_M_linear_Y     <- as.data.frame(datamaker.s4.m1(n = 5000, k = 0.3))
dat_logistic_M_linear_Y   <- as.data.frame(datamaker.s4.m2(n = 5000, k = 0.3))
dat_linear_M_logistic_Y   <- as.data.frame(datamaker.s4.m3(n = 5000, k = 0.7))
dat_logistic_M_logistic_Y <- as.data.frame(datamaker.s4.m4(n = 5000, k = 0.3))

## ----eval = FALSE-------------------------------------------------------------
#  regmedint1 <- regmedint(data = dat_linear_M_linear_Y,
#                          yvar = "Y",
#                          avar = "A",
#                          mvar = "M",
#                          cvar = c("C"),
#                          emm_ac_mreg = c("C"),
#                          emm_ac_yreg = c("C"),
#                          emm_mc_yreg = c("C"),
#                          eventvar = NULL,
#                          a0 = 0,
#                          a1 = 1,
#                          m_cde = 0.5012509,
#                          c_cond = -0.0434094,
#                          mreg = "linear",
#                          yreg = "linear",
#                          interaction = TRUE,
#                          casecontrol = FALSE,
#                          na_omit = FALSE)
#  summary(regmedint1)

## ----eval = FALSE-------------------------------------------------------------
#  data1 <- dat_linear_M_linear_Y
#  boot1 <- function(trials){
#    ind <- sample(5000, 5000, replace = TRUE)
#    dat <- data1[ind,]
#  
#    regmedint1 <- regmedint(data = dat,
#                            yvar = "Y",
#                            avar = "A",
#                            mvar = "M",
#                            cvar = c("C"),
#                            emm_ac_mreg = c("C"),
#                            emm_ac_yreg = c("C"),
#                            emm_mc_yreg = c("C"),
#                            eventvar = NULL,
#                            a0 = 0,
#                            a1 = 1,
#                            m_cde = 0.5012509,
#                            c_cond = -0.0434094,
#                            mreg = "linear",
#                            yreg = "linear",
#                            interaction = TRUE,
#                            casecontrol = FALSE,
#                            na_omit = FALSE)
#  
#    out <- summary(regmedint1)
#    cde.est.boot <- out$summary_myreg[1,1]
#    pnde.est.boot <- out$summary_myreg[2,1]
#    tnie.est.boot <- out$summary_myreg[3,1]
#    tnde.est.boot <- out$summary_myreg[4,1]
#    pnie.est.boot <- out$summary_myreg[5,1]
#    te.est.boot <- out$summary_myreg[6,1]
#    pm.est.boot <- out$summary_myreg[7,1]
#    return(c(cde.est.boot,
#             pnde.est.boot, tnie.est.boot,
#             tnde.est.boot, pnie.est.boot,
#             te.est.boot, pm.est.boot))
#  }
#  
#  set.seed(seed)
#  system.time({
#    results1 <- mclapply(trials, boot1, mc.cores = numCores)
#  })
#  
#  results1.df <- as.data.frame(do.call(rbind, results1))
#  apply(results1.df, 2, mean)
#  apply(results1.df, 2, sd)

## ----eval = FALSE-------------------------------------------------------------
#  regmedint2 <- regmedint(data = dat_logistic_M_linear_Y,
#                          yvar = "Y",
#                          avar = "A",
#                          mvar = "M",
#                          cvar = c("C"),
#                          emm_ac_mreg = c("C"),
#                          emm_ac_yreg = c("C"),
#                          emm_mc_yreg = c("C"),
#                          eventvar = NULL,
#                          a0 = 0,
#                          a1 = 1,
#                          m_cde = 0,
#                          c_cond = -0.0434094,
#                          mreg = "logistic",
#                          yreg = "linear",
#                          interaction = TRUE,
#                          casecontrol = FALSE,
#                          na_omit = FALSE)
#  summary(regmedint2)

## ----eval = FALSE-------------------------------------------------------------
#  data2 <- dat_logistic_M_linear_Y
#  boot2 <- function(trials){
#    ind <- sample(5000, 5000, replace = TRUE)
#    dat <- data2[ind,]
#  
#    regmedint2 <- regmedint(data = dat,
#                            yvar = "Y",
#                            avar = "A",
#                            mvar = "M",
#                            cvar = c("C"),
#                            emm_ac_mreg = c("C"),
#                            emm_ac_yreg = c("C"),
#                            emm_mc_yreg = c("C"),
#                            eventvar = NULL,
#                            a0 = 0,
#                            a1 = 1,
#                            m_cde = 0,
#                            c_cond = -0.0434094,
#                            mreg = "logistic",
#                            yreg = "linear",
#                            interaction = TRUE,
#                            casecontrol = FALSE,
#                            na_omit = FALSE)
#  
#    out <- summary(regmedint2)
#    cde.est.boot <- out$summary_myreg[1,1]
#    pnde.est.boot <- out$summary_myreg[2,1]
#    tnie.est.boot <- out$summary_myreg[3,1]
#    tnde.est.boot <- out$summary_myreg[4,1]
#    pnie.est.boot <- out$summary_myreg[5,1]
#    te.est.boot <- out$summary_myreg[6,1]
#    pm.est.boot <- out$summary_myreg[7,1]
#    return(c(cde.est.boot,
#             pnde.est.boot, tnie.est.boot,
#             tnde.est.boot, pnie.est.boot,
#             te.est.boot, pm.est.boot))
#  }
#  
#  set.seed(seed)
#  system.time({
#    results2 <- mclapply(1:100, boot2, mc.cores = numCores)
#  })
#  
#  results2.df <- as.data.frame(do.call(rbind, results2))
#  apply(results2.df, 2, mean)
#  apply(results2.df, 2, sd)

## ----eval = FALSE-------------------------------------------------------------
#  regmedint3 <- regmedint(data = dat_linear_M_logistic_Y,
#                          yvar = "Y",
#                          avar = "A",
#                          mvar = "M",
#                          cvar = c("C"),
#                          emm_ac_mreg = c("C"),
#                          emm_ac_yreg = c("C"),
#                          emm_mc_yreg = c("C"),
#                          eventvar = NULL,
#                          a0 = 0,
#                          a1 = 1,
#                          m_cde = 0.5012509,
#                          c_cond = 0.5,
#                          mreg = "linear",
#                          yreg = "logistic",
#                          interaction = TRUE,
#                          casecontrol = FALSE,
#                          na_omit = FALSE)
#  summary(regmedint3)

## ----eval = FALSE-------------------------------------------------------------
#  data3 <- dat_linear_M_logistic_Y
#  boot3 <- function(trials){
#    ind <- sample(5000, 5000, replace = TRUE)
#    dat <- data3[ind,]
#  
#    regmedint3 <- regmedint(data = dat,
#                            yvar = "Y",
#                            avar = "A",
#                            mvar = "M",
#                            cvar = c("C"),
#                            emm_ac_mreg = c("C"),
#                            emm_ac_yreg = c("C"),
#                            emm_mc_yreg = c("C"),
#                            eventvar = NULL,
#                            a0 = 0,
#                            a1 = 1,
#                            m_cde = 0.5012509,
#                            c_cond = 0.5,
#                            mreg = "linear",
#                            yreg = "logistic",
#                            interaction = TRUE,
#                            casecontrol = FALSE,
#                            na_omit = FALSE)
#  
#    out <- summary(regmedint3)
#    cde.est.boot <- out$summary_myreg[1,1]
#    pnde.est.boot <- out$summary_myreg[2,1]
#    tnie.est.boot <- out$summary_myreg[3,1]
#    tnde.est.boot <- out$summary_myreg[4,1]
#    pnie.est.boot <- out$summary_myreg[5,1]
#    te.est.boot <- out$summary_myreg[6,1]
#    pm.est.boot <- out$summary_myreg[7,1]
#    return(c(cde.est.boot,
#             pnde.est.boot, tnie.est.boot,
#             tnde.est.boot, pnie.est.boot,
#             te.est.boot, pm.est.boot))
#  }
#  
#  set.seed(seed)
#  system.time({
#    results3 <- mclapply(trials, boot3, mc.cores = numCores)
#  })
#  
#  results3.df <- as.data.frame(do.call(rbind, results3))
#  apply(results3.df, 2, mean)
#  apply(results3.df, 2, sd)

## ----eval = FALSE-------------------------------------------------------------
#  regmedint4 <- regmedint(data = dat_logistic_M_logistic_Y,
#                          yvar = "Y",
#                          avar = "A",
#                          mvar = "M",
#                          cvar = c("C"),
#                          emm_ac_mreg = c("C"),
#                          emm_ac_yreg = c("C"),
#                          emm_mc_yreg = c("C"),
#                          eventvar = NULL,
#                          a0 = 0,
#                          a1 = 1,
#                          m_cde = 0,
#                          c_cond = -0.0434094,
#                          mreg = "logistic",
#                          yreg = "logistic",
#                          interaction = TRUE,
#                          casecontrol = FALSE,
#                          na_omit = FALSE)
#  summary(regmedint4)

## ----eval = FALSE-------------------------------------------------------------
#  data4 <- dat_logistic_M_logistic_Y
#  boot4 <- function(trials){
#    ind <- sample(5000, 5000, replace = TRUE)
#    dat <- data4[ind,]
#  
#    regmedint4 <- regmedint(data = dat,
#                            yvar = "Y",
#                            avar = "A",
#                            mvar = "M",
#                            cvar = c("C"),
#                            emm_ac_mreg = c("C"),
#                            emm_ac_yreg = c("C"),
#                            emm_mc_yreg = c("C"),
#                            eventvar = NULL,
#                            a0 = 0,
#                            a1 = 1,
#                            m_cde = 0,
#                            c_cond = -0.0434094,
#                            mreg = "logistic",
#                            yreg = "logistic",
#                            interaction = TRUE,
#                            casecontrol = FALSE,
#                            na_omit = FALSE)
#  
#    out <- summary(regmedint4)
#    cde.est.boot <- out$summary_myreg[1,1]
#    pnde.est.boot <- out$summary_myreg[2,1]
#    tnie.est.boot <- out$summary_myreg[3,1]
#    tnde.est.boot <- out$summary_myreg[4,1]
#    pnie.est.boot <- out$summary_myreg[5,1]
#    te.est.boot <- out$summary_myreg[6,1]
#    pm.est.boot <- out$summary_myreg[7,1]
#    return(c(cde.est.boot,
#             pnde.est.boot, tnie.est.boot,
#             tnde.est.boot, pnie.est.boot,
#             te.est.boot, pm.est.boot))
#  }
#  
#  set.seed(seed)
#  system.time({
#    results4 <- mclapply(trials, boot4, mc.cores = numCores)
#  })
#  
#  results4.df <- as.data.frame(do.call(rbind, results4))
#  apply(results4.df, 2, mean)
#  apply(results4.df, 2, sd)

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
m_lin_y_lin <- cbind.data.frame(c(0.54832158, 0.37202753, 0.28120386, 0.58513575,
                                  0.06809564, 0.65323139, 0.43048124),
                                c(0.02201021, 0.02273628, 0.01480052, 0.02334807,
                                  0.01196713, 0.02075177, 0.02380022),
                                c(0.5476528, 0.3719104, 0.2807417, 0.5843535,
                                  0.0682987, 0.6526522, 0.4304126),
                                c(0.02170323, 0.02241993, 0.01490996, 0.02312960,
                                  0.01233101, 0.02123155, 0.02344534))
row.names(m_lin_y_lin) <- c("CDE", "PNDE", "TNIE", "TNDE", "PNIE", "TE", "PM")
colnames(m_lin_y_lin) <- c(rep(c("Point Estimate", "Standard Error"), 2))


m_log_y_lin <- cbind.data.frame(c(0.2674768, 0.5532311, 0.0869584, 0.6227790,
                                  0.0174105, 0.6401895, 0.1358323),
                                c(0.02753958, 0.02144037, 0.01342216, 0.02032353,
                                  0.00459631, 0.02035298, 0.02033647),
                                c(0.27144584, 0.55465628, 0.08809824, 0.62500131,
                                  0.01775321, 0.64275452, 0.13703290),
                                c(0.02890304, 0.02129513, 0.01480665, 0.01874403,
                                  0.00467464, 0.01879988, 0.02272391))

m_lin_y_log <- cbind.data.frame(c(0.9731831, 1.0001259, 0.6608177, 0.6089993,
                                  1.0519444, 1.6609436, 0.5969717),
                                c(0.2696701, 0.2838602, 0.2557117, 0.3558141,
                                  0.3044409, 0.1614044, 0.1616112),
                                c(0.9779244, 1.0044763, 0.6606327, 0.6078226,
                                  1.0572864, 1.6651091, 0.5776469),
                                c(0.2712117, 0.2857491, 0.2528156, 0.3542694,
                                  0.3059525, 0.1599455, 0.1685690))

m_log_y_log <- cbind.data.frame(c(0.20341749, 0.76137841, 0.06535229, 0.82960632,
                                  -0.00287562, 0.82673070, 0.11246227),
                                c(0.11831758, 0.08613598, 0.01561403, 0.08759429,
                                  0.01138042, 0.08688896, 0.02606395),
                                c(0.20089667, 0.76132524, 0.06497380, 0.82951442,
                                  -0.00321537, 0.82629904, 0.11228721),
                                c(0.12168979, 0.08675318, 0.01562340, 0.08783860,
                                  0.01164672, 0.08757983, 0.02634418))

row_name <- c("CDE", "PNDE", "TNIE", "TNDE", "PNIE", "TE", "PM")
col_name <- c(rep(c("Point Estimate", "Standard Error"), 2))
row.names(m_lin_y_lin) <- row.names(m_log_y_lin) <-
  row.names(m_lin_y_log) <- row.names(m_log_y_log) <- row_name
colnames(m_lin_y_lin) <- colnames(m_log_y_lin) <-
  colnames(m_lin_y_log) <- colnames(m_log_y_log) <- col_name

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
# output table
library(kableExtra)
library(formattable)

kbl1 <- knitr::kable(m_lin_y_lin, align = "cccc", col.names = col_name,  digits = 8)
kbl2 <- knitr::kable(m_log_y_lin, align = "cccc", col.names = col_name,  digits = 8)
kbl3 <- knitr::kable(m_lin_y_log, align = "cccc", col.names = col_name,  digits = 8)
kbl4 <- knitr::kable(m_log_y_log, align = "cccc", col.names = col_name,  digits = 8)

# formatting:
# https://haozhu233.github.io/kableExtra/awesome_table_in_html.html

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
kbl1 %>%
  kable_classic(html_font = "Garamond") %>%
  add_header_above(c(" " = 1, "Non-bootstrap" = 2, "Bootstrap" = 2))

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
kbl2 %>%
  kable_classic(html_font = "Garamond") %>%
  add_header_above(c(" " = 1, "Non-bootstrap" = 2, "Bootstrap" = 2))

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
kbl3 %>%
  kable_classic(html_font = "Garamond") %>%
  add_header_above(c(" " = 1, "Non-bootstrap" = 2, "Bootstrap" = 2))

## ----message = FALSE, tidy = FALSE, echo = F----------------------------------
kbl4 %>%
  kable_classic(html_font = "Garamond") %>%
  add_header_above(c(" " = 1, "Non-bootstrap" = 2, "Bootstrap" = 2))

