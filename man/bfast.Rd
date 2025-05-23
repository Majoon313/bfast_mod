% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bfast.R
\name{bfast}
\alias{bfast}
\title{Break Detection in the Seasonal and Trend Component of a Univariate Time
Series}
\usage{
bfast(
  Yt,
  h = 0.15,
  season = c("dummy", "harmonic", "none"),
  max.iter = 10,
  breaks = NULL,
  hpc = "none",
  level = 0.05,
  decomp = c("stl", "stlplus"),
  type = "OLS-MOSUM",
  ...
)
}
\arguments{
\item{Yt}{univariate time series to be analyzed. This should be an object of
class "ts" with a frequency greater than one.}

\item{h}{minimal segment size between potentially detected breaks in the
trend model given as fraction relative to the sample size (i.e. the minimal
number of observations in each segment divided by the total length of the
timeseries).}

\item{season}{the seasonal model used to fit the seasonal component and
detect seasonal breaks (i.e. significant phenological change).  There are
three options: "dummy", "harmonic", or "none" where "dummy" is the model
proposed in the first Remote Sensing of Environment paper and "harmonic" is
the model used in the second Remote Sensing of Environment paper (See paper
for more details) and where "none" indicates that no seasonal model will be
fitted (i.e. St = 0 ). If there is no seasonal cycle (e.g. frequency of the
time series is 1) "none" can be selected to avoid fitting a seasonal model.}

\item{max.iter}{maximum amount of iterations allowed for estimation of
breakpoints in seasonal and trend component.}

\item{breaks}{either an integer specifying the number of breaks to compute,
or a string specifying a statistic with which to compute
the optimal number of breakpoints (see \code{\link[strucchangeRcpp:breakpoints]{strucchangeRcpp::breakpoints()}} for
more information). If one value is given, it is used for both the trend and
seasonal components, and if two are given, the first one is considered to be
for the trend and the second for the seasonal component.}

\item{hpc}{A character specifying the high performance computing support.
Default is "none", can be set to "foreach". Install the "foreach" package
for hpc support.}

\item{level}{numeric; threshold value for the \link[strucchangeRcpp]{sctest.efp}
test; if a length 2 vector is passed, the first value is used for the trend,
the second for the seasonality}

\item{decomp}{"stlplus" or "stl": the function to use for decomposition.
\code{stl} can handle sparse time series (1 < frequency < 4), \code{stlplus}
can handle \code{NA} values in the time series.}

\item{type}{character, indicating the type argument to
\link[strucchangeRcpp]{efp}}

\item{\dots}{additional arguments passed to \code{\link[stlplus:stlplus]{stlplus::stlplus()}}, if
its usage has been enabled, otherwise ignored.}
}
\value{
An object of the class "bfast" is a list with the following
elements: \item{Yt}{ equals the Yt used as input.} \item{output}{ is a list
with the following elements (for each iteration): \tabular{ll}{ \code{Tt}
\tab the fitted trend component\cr \code{St} \tab the fitted seasonal
component\cr \code{Nt} \tab the noise or remainder component\cr \code{Vt}
\tab equals the deseasonalized data \code{Yt - St} for each iteration\cr
\code{bp.Vt} \tab output of the \code{\link[strucchangeRcpp]{breakpoints}}
function for the trend model. Note that the output breakpoints are index
numbers of \code{na.omit(as.numeric(Vt))}.\cr \code{ci.Vt} \tab output of the
\code{\link[strucchangeRcpp]{breakpoints}} confint function for the trend
model\cr \code{Wt} \tab equals the detrended data \code{Yt - Tt} for each
iteration\cr \code{bp.Wt} \tab output of the
\code{\link[strucchangeRcpp]{breakpoints}} function for the seasonal model.
Note that the output breakpoints are index numbers of \code{na.omit(as.numeric(Wt))}. \cr
\code{ci.Wt} \tab output of the \code{\link[strucchangeRcpp]{breakpoints}}
confint function for the seasonal model }} \item{nobp}{ is a list with the
following elements: \tabular{ll}{ \code{nobp.Vt} \tab logical, TRUE if there
are no breakpoints detected\cr \code{nobp.Wt} \tab logical, TRUE if there
are no breakpoints detected }} \item{Magnitude}{ magnitude of the biggest
change detected in the trend component} \item{Time}{ timing of the biggest
change detected in the trend component}
}
\description{
Iterative break detection in seasonal and trend component of a time series.
Seasonal breaks is a function that combines the iterative decomposition of
time series into trend, seasonal and remainder components with significant
break detection in the decomposed components of the time series.
}
\details{
The algorithm decomposes the input time series \code{Yt} into three components:
trend, seasonality and remainder, using the function defined by the \code{decomp}
parameter. Then each component is checked for at least one significant
break using \code{\link[strucchangeRcpp:efp]{strucchangeRcpp::efp()}}, and if there is one, \code{\link[strucchangeRcpp:breakpoints]{strucchangeRcpp::breakpoints()}}
is run on the component. The result allows differentiating between breaks in
trend and seasonality.
}
\examples{
## Simulated Data
plot(simts) # stl object containing simulated NDVI time series
datats <- ts(rowSums(simts$time.series))
# sum of all the components (season,abrupt,remainder)
tsp(datats) <- tsp(simts$time.series) # assign correct time series attributes
plot(datats)

fit <- bfast(datats, h = 0.15, season = "dummy", max.iter = 1)
plot(fit, sim = simts)
fit
# prints out whether breakpoints are detected
# in the seasonal and trend component
 
## Real data
## The data should be a regular ts() object without NA's
## See Fig. 8 b in reference
plot(harvest, ylab = "NDVI")
# MODIS 16-day cleaned and interpolated NDVI time series

(rdist <- 10/length(harvest))
# ratio of distance between breaks (time steps) and length of the time series

fit <- bfast(harvest, h = rdist, season = "harmonic", max.iter = 1, breaks = 2)
plot(fit)
## plot anova and slope of the trend identified trend segments
plot(fit, ANOVA = TRUE)
## plot the trend component and identify the break with
## the largest magnitude of change
plot(fit, type = "trend", largest = TRUE)

## plot all the different available plots
plot(fit, type = "all")

## output
niter <- length(fit$output) # nr of iterations
out <- fit$output[[niter]]
# output of results of the final fitted seasonal and trend models and
## #nr of breakpoints in both.

## running bfast on yearly data
t <- ts(as.numeric(harvest), frequency = 1, start = 2006)
fit <- bfast(t, h = 0.23, season = "none", max.iter = 1)
plot(fit)
fit

## handling missing values with stlplus
(NDVIa <- as.ts(zoo::zoo(som$NDVI.a, som$Time)))
fit <- bfast(NDVIa, season = "harmonic", max.iter = 1, decomp = "stlplus")
plot(fit)
fit
}
\references{
\insertRef{janbfast}{bfast}

\insertRef{janbfastpheno}{bfast}
}
\seealso{
\code{\link[bfast]{plot.bfast}} for plotting of bfast() results.
\cr \code{\link[strucchangeRcpp]{breakpoints}} for more examples and background
information about estimation of breakpoints in time series.
}
\author{
Jan Verbesselt
}
\keyword{ts}
