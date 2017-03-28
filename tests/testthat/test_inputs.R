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
