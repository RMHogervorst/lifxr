% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lifx-cloud.R
\name{power}
\alias{power}
\title{power}
\usage{
power(state = c("on", "off"), selector = "all", duration = 1)
}
\arguments{
\item{state}{on or off?}

\item{selector}{a string in format '[type]:[value]', where type can be 
'all', 'id', 'label', 'group', 'group_id', 'location', 'location_id', 
'scene_id', and value is what you want to target. The default is 'all',
which needs no value argument.}

\item{duration}{the length of the effect}
}
\value{
httr response object
}
\description{
power lights on or off with a fade duration
}
\details{
Not exported because it conflicts with stats::power. see on() and off()
}
