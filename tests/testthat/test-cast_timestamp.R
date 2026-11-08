test_that("string", {
  expect_equal(
    cast_timestamp("2015-07-01T20:10:30.781Z"),
    "2015-07-01T20:10:30.781Z"
  )
})

test_that("POSIXlt", {
  ts <- strptime(
    "2015-07-01T20:10:30",
    format = "%Y-%m-%dT%H:%M:%S",
    tz = "UTC"
  )
  expect_equal(cast_timestamp(ts), "1435781430")
})

test_that("POSIXct", {
  ts <- as.POSIXct("2015-07-01 20:10:30", tz = "UTC")
  expect_equal(cast_timestamp(ts), "1435781430")
  expect_equal(cast_timestamp(ts + 0.5), "1435781430.5")
})

test_that("unix seconds", {
  expect_equal(cast_timestamp(42424242), "42424242")
})

test_that("round unix seconds are not in scientific notation", {
  expect_equal(cast_timestamp(1.7e9), "1700000000")
})

test_that("integer unix seconds", {
  expect_equal(cast_timestamp(1700000000L), "1700000000")
})
