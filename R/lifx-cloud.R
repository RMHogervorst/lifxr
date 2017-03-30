## SEE Docs: https://api.lifx.com/

BASE <- "https://api.lifx.com"
VERSION <- "v1"

get_accesstoken <- function(){
    key <- Sys.getenv("LIFX_PAT", unset = NA)
    if(is.na(key))stop("No key found")
    key
}
check_hue <- function(hue){
    if(hue < 0 | hue > 360){
        stop("hue needs to be between 0 and 360")
        }
    hue
}
check_saturation <- function(value){
    if(value < 0 | value > 1){
        stop("saturation needs to be between 0 and 1")
        }
    value
}
check_brightness <- function(value){
    if(value < 0 | value > 1){
        stop("brightness needs to be between 0 and 1")
        }
    value
}

#' Checks headers of incoming message for rate limiting
#' will complain if rate limit is less then 5. 
#' when it reaches 0 it will tell you when you can try again.
#' For internal use.
rate_limit_warner <- function(results){
    headers <- headers(results)
    attemps_this_epoch <- as.integer(headers$`x-ratelimit-remaining`)
    next_epoch <- as.POSIXlt(as.numeric(headers$`x-ratelimit-reset`), 
                             origin = "1970-01-01", tz = "")
    if(attemps_this_epoch <5){warning("Rate-limit warning: only ", 
                                      attemps_this_epoch, 
                                      " attempts possible untill the next cycle at ",
                                      next_epoch, " local time")}
}
## kelvin:[2500-9000]  # maar geef boodschap als ook saturation gegeven, slaat
check_kelvin <- function(value){
    if(value < 2500 | value > 9000){
        stop("kelvin needs to be between 2500 and 9000")
        }
    value
}
## saturation over, want zit al in kelvin.
# arguments name:[0-9]
# except color. 



#' ping
#' 
#' ping the lifx API and get a status reply
#' @import httr
#' @import jsonlite
#' @export
ping <- function(){
  results <- GET(paste0(BASE, "/", VERSION, "/lights.json"),
                 query = list(access_token = get_accesstoken()))
  rate_limit_warner(results)
  if(results$status_code != 200)
    message("LIFX bulbs could not be reached")
  else
    message("ping! LIFX is active.")
}

#' lights
#' 
#' list lights, their status and properties
#' @param selector a string in format '[type]:[value]', where type can be 
#' 'all', 'id', 'label', 'group', 'group_id', 'location', 'location_id', 
#' 'scene_id', and value is what you want to target. The default is 'all',
#' which needs no value argument. 
#' @return a list of all lights, status, and properties 
#' @export
lights <- function(selector = "all"){
  results <- GET(paste0(BASE, "/", VERSION, "/lights/", selector),
                 query = list(access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text", encoding = "utf-8"),
                     simplifyDataFrame = F)
}

#' current color
#' 
#' list of the current colors, in a format valid for \code{\link{color}}
#' @inheritParams lights
#' @return httr response object
#' @export
current_color <- function(selector = "all"){
  light_list <- lights(selector = selector)
  sapply(light_list, 
         function(light){
           if(light$color[["saturation"]] > 0)
             paste("hsb:",
                   light$color[["hue"]], ",",
                   light$color[["saturation"]], ",",
                   light$brightness,
                   sep = "")
             else 
               paste("kelvin:", 
                     light$color[["kelvin"]], 
                     " brightness:",
                     light$brightness * 100, "%", 
                     sep = "")
         })
}


#' toggle
#' 
#' toggle lights on and off
#' @inheritParams lights
#' @return httr response object
#' @export
toggle <- function(selector = "all"){
  results <- POST(paste0(BASE, "/", VERSION, "/lights/", selector, 
                         "/toggle.json"), 
       query = list(access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}

#' power
#' 
#' power lights on or off with a fade duration
#' @param state on or off?
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @details Not exported because it conflicts with stats::power. see on() and off()
power <- function(state = c("on", "off"), selector = "all", duration = 1.0){
  state <- match.arg(state)
  results <- PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/state.json"), 
      query = list(power = state, 
                   duration = duration, 
                   access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}


#' off
#' 
#' power lights off with a fade duration
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @export
off <-  function(selector = "all", duration = 1.0){
  power("off", selector = selector, duration = duration)
}


#' on
#' 
#' power lights on 
#' @param duration the length of the effect
#' @inheritParams lights
#' @return httr response object
#' @export
on <- function(selector = "all", duration = 1.0){
  power("on", selector = selector, duration = duration)
}


#' color
#' 
#' set lifx color
#' @param color a string describing the desired color; see examples.
#' @param duration the length of the effect
#' @param power_on should the light be powered on if it is off? (FALSE just leaves light off)
#' @inheritParams lights
#' @details Note that the kelvin temperature ranges from 2700 to 8000. Hue in HSB list is 
#' a number between 0 and 360, whereas saturation and brightness should be between 0 and 1.
#' 
#' @examples \dontrun{
#'  color("green", "label:desk")   # deep green, brightness untouched on lights labeled 'desk'
#'  color("blue brightness:100%")  # deep blue, maximum brightness
#'  color("hsb:0,1,1")             # deep red, maximum brightness
#'  color("random")                # random hue, maximum saturation, brightness untouched
#'  color("kelvin:2700")           # warm white, brightness untouched
#'  color("saturation:100%")       # set maximum saturation
#' }
#' @return httr response object
#' @export
color <- function(color, selector="all", duration = 1.0, power_on = TRUE){
  results <- PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/state.json"), 
      query = list(color = color, 
                   duration = duration, 
                   power_on = power_on,
                   access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}


#' breathe
#' 
#' Display a breathe effect
#' @param from_color Same syntax as color, defaults to current color (of first bulb in selection)
#' @param period time in seconds for the cycle to take place
#' @param cycles number of cycles to perform
#' @param persist should the color persist after the effect? default is FALSE (returns to original color)
#' @param peak when in the cycle should the color be at it's maximum intensity?
#' @inheritParams color
#' @examples \dontrun{
#' breathe("purple", "blue")
#' }
#' @export
breathe <- function(color, from_color = current_color(selector), 
                    period = 10.0, cycles = 2, persist = FALSE,
                    peak = 0.5, selector="all", power_on = TRUE){
  settings <- list(color = color, 
                   from_color = from_color,
                   period = period,
                   cycles = cycles,
                   persist = persist,
                   peak = peak,
                   power_on = power_on,
                   access_token = get_accesstoken())
  results <- POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/effects/breathe"),
       query = settings)
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}

#' pulse
#' 
#' pulse a color for a defined period
#' @inheritParams breathe
#' @param duty_cycle Ratio of the period where color is active. Only used for pulse. Defaults to 0.5. Range: 0-1
#' @return httr response object
#' @export
pulse <- function(color, from_color = current_color(selector)[[1]], 
                  period = 5.0, cycles = 1, persist = FALSE,
                   duty_cycle = 0.5, selector="all", power_on = TRUE){
  settings <- list(color = color, 
                   from_color = from_color,
                   period = period,
                   cycles = cycles,
                   persist = persist,
                   duty_cycle = duty_cycle,
                   power_on = power_on,
                   access_token = get_accesstoken())
  results <- POST(paste0(BASE, "/", VERSION, "/lights/", selector, "/effects/pulse.json"),
       query = settings)
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}

#' label
#' 
#' add a label to a bulb
#' @param label the label for the bulb
#' @param selector selector pattern for a single bubl, e.g. id:<idstring>
#' @return httr response object
#' @export
label <- function(label, selector) {
  PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/label.json"), 
      query = list(label = label, 
                   access_token = get_accesstoken()))
}

#' scene
#' 
#' turn on a scene for a bulb
#' @inheritParams power
#' @param scene_id the id of the desired scene
#' @return httr response object
#' @export
scene <- function(state = c("on", "off"), scene_id, duration = 1.0){
  state <- match.arg(state)
  results <- PUT(paste0(BASE, "/", VERSION, "/scenes/scene_id:", scene_id, "/activate.json"), 
      query = list(state = state, 
                   duration = duration, 
                   access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}

#' Lists all the scenes available in the users account
#' 
#' @return httr response object
#' @export
get_scenes <- function(){
    results <- GET(paste0(BASE, "/", VERSION, "/scenes.json"),
        query = list(access_token = get_accesstoken()))
    rate_limit_warner(results)
    jsonlite::fromJSON(content(results, as = "text"))
}



#' parse color
#'
#' Parse a color string and return hue, saturation, brightness and kelvin values
#' @param string The color string to parse
#' @return hsbk information for the string. 
#' @export
parse_color <- function(string){
  results <- GET(paste0(BASE, "/", VERSION, "/color"), 
                 query = list(string = string,
                              access_token = get_accesstoken()))
  rate_limit_warner(results)
  jsonlite::fromJSON(content(results, as = "text"))
}

#' Set the state, a general function
#' 
#' @param selector Which lights do you want? defaults to "all"
#' @param power either on or off, defaults to on, makes not sense to shut the light off and change the color
#' @param color a name or combination of hue, brightness, saturation etc.
#' @param brightness between 0-1 how much light must the bulb emit
#' @param saturation between 0-1 how much color do you want to add to white
#' @param duration a fade duration in seconds, f.i. 1 second
#' @export
set_state <- function(selector ="all", power = "on", color= NULL, 
                      brightness = NULL, saturation= NULL,
                      duration = 1.0){
    if(!is.null(brightness)){brightness <- check_brightness(brightness)}
    if(!is.null(saturation)){brightness <- check_saturation(saturation)}
    #if(grepl("hue", color)){} # extract hue and check for hue:number and check hue.
    result <- PUT(paste0(BASE, "/", VERSION, "/lights/", selector, "/state.json"), 
                  query = list(power = power,
                               color= color,
                               duration = duration,
                               brightness = brightness,
                               saturation = saturation, # doesn't work. because needs to be in color.
                               access_token = get_accesstoken())
    )
    rate_limit_warner(results)
    httr::content(result)
}


