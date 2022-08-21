
start_ts <- strptime(
  "2015-07-01T20:10:30",
  format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"
)
end_ts <- strptime(
  "2015-07-01T20:11:00",
  format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"
)

# nolint start: line_length_linter
test_that("all params", {
  got <- build_url("http://127.0.0.1:9090/", "bananas", start_ts, end_ts, "42s", "1m")
  expect_equal(got, "http://127.0.0.1:9090/api/v1/query_range?query=bananas&start=1435781430&end=1435781460&step=42s&timeout=1m")
})

test_that("no optional params", {
  got <- build_url("http://127.0.0.1:9090/", "up", start_ts, end_ts, "10s")
  expect_equal(got, "http://127.0.0.1:9090/api/v1/query_range?query=up&start=1435781430&end=1435781460&step=10s")
})

test_that("base url without slash", {
  got <- build_url("http://127.0.0.1:9090", "bananas", start_ts, end_ts, "10s")
  expect_equal(got, "http://127.0.0.1:9090/api/v1/query_range?query=bananas&start=1435781430&end=1435781460&step=10s")
})

test_that("base url without port", {
  got <- build_url("http://127.0.0.1/", "bananas", start_ts, end_ts, "10s")
  expect_equal(got, "http://127.0.0.1/api/v1/query_range?query=bananas&start=1435781430&end=1435781460&step=10s")
})

test_that("https base url", {
  got <- build_url("https://127.0.0.1:8080/", "bananas", start_ts, end_ts, "10s")
  expect_equal(got, "https://127.0.0.1:8080/api/v1/query_range?query=bananas&start=1435781430&end=1435781460&step=10s")
})

test_that("string timestamp", {
  got <- build_url("https://127.0.0.1:8080/", "bananas", "2015-07-01T20:10:30.781Z", "2022-08-20T00:02:30.331Z", "10s")
  expect_equal(got, "https://127.0.0.1:8080/api/v1/query_range?query=bananas&start=2015-07-01T20:10:30.781Z&end=2022-08-20T00:02:30.331Z&step=10s")
})

test_that("unix timestamp, string", {
  got <- build_url("https://127.0.0.1:8080/", "bananas", "242424", "424242", "10s")
  expect_equal(got, "https://127.0.0.1:8080/api/v1/query_range?query=bananas&start=242424&end=424242&step=10s")
})

test_that("unix timestamp, numerical", {
  got <- build_url("https://127.0.0.1:8080/", "bananas", 242424, 424242, "10s")
  expect_equal(got, "https://127.0.0.1:8080/api/v1/query_range?query=bananas&start=242424&end=424242&step=10s")
})

test_that("aggregate", {
  q <- 'sum by (result) (rate(dml_handler_write_duration_seconds_count{handler="request"}[1m]))'
  got <- build_url("http://127.0.0.1:9090/", q, "2022-08-19T00:00:00Z", "2022-08-20T00:00:00Z", "10s")
  expect_equal(got, "http://127.0.0.1:9090/api/v1/query_range?query=sum%20by%20%28result%29%20%28rate%28dml_handler_write_duration_seconds_count%7bhandler%3d%22request%22%7d%5b1m%5d%29%29&start=2022-08-19T00:00:00Z&end=2022-08-20T00:00:00Z&step=10s")
})
# nolint end
