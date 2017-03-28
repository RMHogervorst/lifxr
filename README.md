<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/rmhogervorst/lifxr.svg?branch=master)](https://travis-ci.org/rmhogervorst/lifxr)

LIFX
====

Quickstart
----------

Install the package:

``` r
devtools::install_github("rmhogervorst/lifxr")
```

Get your Personal Authentication Token from the LIFX cloud: <https://cloud.lifx.com/settings>. Add this token into R using `options()` in your `.Rprofile` or current session:

``` r
options(LIFX_PAT = "<TOKEN>")
```

You can now load the library and control your lights:

``` r
library("lifxr")
lights()
on()
off()
```

Function overview
-----------------

All endpoints in `v1` of [api.lifx.com](https://api.lifx.com) are implemented, along with a few helper functions.

-   `on()` Turn a light or group of lights on
-   `off()` Turn a light group off
-   `breathe()` run the breathe effect on a light group (with desired settings)
-   `color()` change the color of a light or group
-   `label()` add a label to a light
-   `lights()` List all lights and their status
-   `pulse()` run the pulse effect
-   `scene()` switch to a certain preset scene
-   `toggle()` toggle lights on or off
-   `get_scenes()` get all the scenes

<!-- API not working? 
- `parse_color()` Return the HSBK for a color string
-->
-   `current_color()` return the current color of a light group (in a format appropriate for use with `color`/`breathe`/`pulse`)
-   `ping()` the API to confirm it responds.

See package documentation for details.

Note:
-----

I have copied and modified this package from Carl Boetinger see the original package <https://github.com/cboettig/lifxr>.
