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
set.seed(138087069)
library(regmedint)
library(tidyverse)
## Prepare dataset
data(vv2015)
vv2015 <- vv2015 %>%
    select(-cens) %>%
    ## Generate exposure-dependent missing of mediator
    mutate(logit_p_m_miss = -1 + 0.5 * x,
           p_m_miss = exp(logit_p_m_miss) / (1 + exp(logit_p_m_miss)),
           ## Indicator draw
           ind_m_miss = rbinom(n = length(p_m_miss), size = 1, prob = p_m_miss),
           m_true = m,
           m = if_else(ind_m_miss == 1L, as.numeric(NA), m))

## -----------------------------------------------------------------------------
regmedint_true <-
    regmedint(data = vv2015,
              ## Variables
              yvar = "y",
              avar = "x",
              mvar = "m_true",
              cvar = c("c"),
              eventvar = "event",
              ## Values at which effects are evaluated
              a0 = 0,
              a1 = 1,
              m_cde = 1,
              c_cond = 0.5,
              ## Model types
              mreg = "logistic",
              yreg = "survAFT_weibull",
              ## Additional specification
              interaction = TRUE,
              casecontrol = FALSE)
summary(regmedint_true)

## -----------------------------------------------------------------------------
regmedint_cca <- vv2015 %>%
    filter(!is.na(m)) %>%
    regmedint(data = .,
              ## Variables
              yvar = "y",
              avar = "x",
              mvar = "m",
              cvar = c("c"),
              eventvar = "event",
              ## Values at which effects are evaluated
              a0 = 0,
              a1 = 1,
              m_cde = 1,
              c_cond = 0.5,
              ## Model types
              mreg = "logistic",
              yreg = "survAFT_weibull",
              ## Additional specification
              interaction = TRUE,
              casecontrol = FALSE)
summary(regmedint_cca)

## -----------------------------------------------------------------------------
library(mice)
vv2015_mod <- vv2015 %>%
    mutate(log_y = log(y)) %>%
    select(x,m,c,log_y,event)
## Run mice
vv2015_mice <- mice(data = vv2015_mod, m = 50, printFlag = FALSE)
## Object containig 50 imputed dataset
vv2015_mice

## -----------------------------------------------------------------------------
## Fit in each MI dataset
vv2015_mice_regmedint <-
    vv2015_mice %>%
    ## Stacked up dataset
    mice::complete("long") %>%
    as_tibble() %>%
    mutate(y = exp(log_y)) %>%
    group_by(.imp) %>%
    ## Nested data frame
    nest() %>%
    mutate(fit = map(data, function(data) {
        regmedint(data = data,
                  ## Variables
                  yvar = "y",
                  avar = "x",
                  mvar = "m",
                  cvar = c("c"),
                  eventvar = "event",
                  ## Values at which effects are evaluated
                  a0 = 0,
                  a1 = 1,
                  m_cde = 1,
                  c_cond = 0.5,
                  ## Model types
                  mreg = "logistic",
                  yreg = "survAFT_weibull",
                  ## Additional specification
                  interaction = TRUE,
                  casecontrol = FALSE)
    })) %>%
    ## Extract point estimates and variance estimates
    mutate(coef_fit = map(fit, coef),
           vcov_fit = map(fit, vcov))
vv2015_mice_regmedint

## -----------------------------------------------------------------------------
regmedint_mi <- mitools::MIcombine(results = vv2015_mice_regmedint$coef_fit,
                                   variances = vv2015_mice_regmedint$vcov_fit)
regmedint_mi_summary <- summary(regmedint_mi)

## -----------------------------------------------------------------------------
cbind(true = coef(regmedint_true),
      cca = coef(regmedint_cca),
      mi = regmedint_mi_summary$results)

