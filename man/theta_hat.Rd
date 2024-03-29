% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/06_calc_myreg_helpers_coef.R
\name{theta_hat}
\alias{theta_hat}
\title{Create a vector of coefficients from the outcome model (yreg)}
\usage{
theta_hat(
  yreg,
  yreg_fit,
  avar,
  mvar,
  cvar,
  emm_ac_yreg = NULL,
  emm_mc_yreg = NULL,
  interaction
)
}
\arguments{
\item{yreg}{A character vector of length 1. Outcome regression type: \code{"linear"}, \code{"logistic"}, \code{"loglinear"}, \code{"poisson"}, \code{"negbin"}, \code{"survCox"}, \code{"survAFT_exp"}, or \code{"survAFT_weibull"}.}

\item{yreg_fit}{Model fit object for yreg (outcome model).}

\item{avar}{A character vector of length 1. Treatment variable name.}

\item{mvar}{A character vector of length 1. Mediator variable name.}

\item{cvar}{A character vector of length > 0. Covariate names. Use \code{NULL} if there is no covariate. However, this is a highly suspicious situation. Even if \code{avar} is randomized, \code{mvar} is not. Thus, there are usually some confounder(s) to account for the common cause structure (confounding) between \code{mvar} and \code{yvar}.}

\item{emm_ac_yreg}{A character vector of length > 0. Effect modifiers names. The covariate vector in treatment-covariate product term in the outcome model.}

\item{emm_mc_yreg}{A character vector of length > 0. Effect modifiers names. The covariate vector in mediator-covariate product term in outcome model.}

\item{interaction}{A logical vector of length 1. The presence of treatment-mediator interaction in the outcome model. Default to TRUE.}
}
\value{
A named numeric vector of coefficients.
}
\description{
This function extracts \code{\link{coef}} from \code{yreg_fit} and 3s with zeros appropriately to create a named vector consistently having the following elements:
\code{(Intercept)} (a zero element is added for \code{yreg = "survCox"} for which no intercept is estimated (the baseline hazard is left unspecified)),
\code{avar},
\code{mvar},
\code{avar:mvar} (a zero element is added when \code{interaction = FALSE}).
\code{cvar} (this part is eliminated when \code{cvar = NULL}),
\code{emm_ac_yreg} (this part is eliminated when \code{emm_ac_yreg = NULL}),
\code{emm_mc_yreg} (this part is eliminated when \code{emm_mc_yreg = NULL}).
}
