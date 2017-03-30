# tests inputs
context("testing limit testings")


test_that("hue limits are correct", {
    expect_error(check_hue(360.1), "hue needs to be between 0 and 360")
    expect_error(check_hue(-0.5), "hue needs to be between 0 and 360")
})
test_that("saturation limits are correct", {
    expect_error(check_saturation(1.1), "saturation needs to be between 0 and 1")
    expect_error(check_saturation(-0.5), "saturation needs to be between 0 and 1")
})

test_that("saturation limits are correct", {
    expect_error(check_saturation(1.1), "needs to be between 0 and 1")
    expect_error(check_saturation(-0.5), "needs to be between 0 and 1")
})
test_that("brightness limits are correct", {
    expect_error(check_brightness(1.1), "needs to be between")
    expect_error(check_brightness(-0.5), "needs to be between")
})

# test_that("rate limiting throws error", {
#     skip_on_travis()
#     skip_on_cran()
#     if(any(grepl("^testthat.R$", dir()))){ #you're in tests
#         setwd("..")
#     }else if(any(grepl("^testthat.R$", dir("..")))){ # you're in tests/testthat
#         setwd("../..")
#     }else if(any(grepl("^DESCRIPTION$",  dir()))){# you're in the normal wd.
#     }else{ 
#         stop("we don't know in what directory your test is running, something weird is going on")
#     }
#     load("cfm_output.rda")    
#     expect_warning(rate_limit_warner(results),regexp = "Rate-limit warning")
#     
# })

