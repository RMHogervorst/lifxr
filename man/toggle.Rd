% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lifx-cloud.R
\name{toggle}
\alias{toggle}
\title{toggle}
\usage{
toggle(selector = "all")
}
\arguments{
\item{selector}{a string in format '[type]:[value]', where type can be 
'all', 'id', 'label', 'group', 'group_id', 'location', 'location_id', 
'scene_id', and value is what you want to target. The default is 'all',
which needs no value argument.}
}
\value{
httr response object
}
\description{
toggle lights on and off
}
