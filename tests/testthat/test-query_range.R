with_mock_api({
  test_that("query_range returns data", {
    #
    # This test query, and the response, was sourced from the prometheus docs:
    #
    #   https://prometheus.io/docs/prometheus/latest/querying/api/#range-queries
    #

    got <- expect_silent(query_range(
      "up",
      "2015-07-01T20:10:30.781Z",
      "2015-07-01T20:11:00.781Z",
      host = "http://127.0.0.1:9090/", # Explicit host
      step = "15s"
    ))

    # Expected output tibble:
    #
    #    # A tibble: 2 x 4
    #      `__name__` job        instance       values
    #      <chr>      <chr>      <chr>          <list>
    #    1 up         prometheus localhost:9090 <tibble [3 x 2]>
    #    2 up         node       localhost:9091 <tibble [3 x 2]>
    #
    # Unnested:
    #
    #   # A tibble: 6 x 5
    #     `__name__` job        instance       time       value
    #     <chr>      <chr>      <chr>          <chr>      <chr>
    #   1 up         prometheus localhost:9090 1435781430 1
    #   2 up         prometheus localhost:9090 1435781445 1
    #   3 up         prometheus localhost:9090 1435781460 1
    #   4 up         node       localhost:9091 1435781430 0
    #   5 up         node       localhost:9091 1435781445 0
    #   6 up         node       localhost:9091 1435781460 1
    #

    want <- tibble::tibble(
      `__name__` = c("up", "up"),
      job = c("prometheus", "node"),
      instance = c("localhost:9090", "localhost:9091"),
      values = list(
        tibble::tibble(
          timestamp = as.POSIXct(
            c(
              1435781430,
              1435781445,
              1435781460
            ),
            origin = "1970-01-01"
          ),
          value = c(1, 1, 1)
        ),
        tibble::tibble(
          timestamp = as.POSIXct(
            c(
              1435781430,
              1435781445,
              1435781460
            ),
            origin = "1970-01-01"
          ),
          value = c(0, 0, 1)
        )
      ),
    )

    expect_equal(got, want)
  })

  test_that("server side aggregate", {
    # nolint start: line_length_linter
    q <- "sum by (handler, result) (rate(dml_handler_write_duration_seconds_count{}[1m]))"
    # nolint end

    got <- query_range(
      q,
      "2022-08-19T00:00:00Z",
      "2022-08-20T00:00:00Z",
    ) # NOTE: uses default host

    expect_equal(nrow(got), 10)
    expect_equal(unique(got$handler), c(
      "parallel_write",
      "partitioner",
      "request",
      "schema_validator",
      "sharded_write_buffer"
    ))
    expect_equal(unique(got$result), c("error", "success"))
    expect_equal(nrow(got$values[[1]]), 8641)
    expect_equal(ncol(got$values[[1]]), 2)
  })
})
