test_that("string", {
  expect_equal(
    cast_timestamp("2015-07-01T20:10:30.781Z"),
    "2015-07-01T20:10:30.781Z"
  )
})

test_that("POSIXct", {
  ts <- strptime(
    "2015-07-01T20:10:30",
    format = "%Y-%m-%dT%H:%M:%S",
    tz = "UTC"
  )
  expect_equal(cast_timestamp(ts), 1435781430)
})

test_that("unix seconds", {
  expect_equal(cast_timestamp(42424242), 42424242)
})
