context("test api functions")
test_that("env variables are active", {
    expect_true(class(get_accesstoken()) == "character")
})

test_that("normal functions produce result", {
    expect_message(ping(),"LIFX is active")
    expect_equal(parse_color("red")$saturation, 1)
})
