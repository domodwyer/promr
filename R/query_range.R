#' Evaluate an expression query over a range of time.
#'
#' @param query A PromQL query.
#' @param start A RFC3339 timestamp string, numerical unix timestamp, or POSIXct
#'     object.
#' @param end A RFC3339 timestamp string, numerical unix timestamp, or POSIXct
#'     object.
#' @param host An optional host - defaulting to `http://127.0.0.1:9090`
#' @param step An optional query resolution step width, defaulting to `10s`
#' @param timeout An optional query timeout value, defaulting to server-side
#'     limit. Note this timeout is capped to the server-side value.
#' @return A tibble of all series returned by the server, with nested
#'     measurements.
#' @examples
#' \dontrun{
#' # Run a simple range query against the specified host.
#' query_range(
#'   "up",
#'   "2022-08-20T00:00:00Z",
#'   "2022-08-21T00:00:00Z",
#'   host = "http://127.0.0.1:9090"
#' )
#'
#' # Run a server-side aggregation query, using the default local host.
#' query_range(
#'   "rate(http_requests_total[5m])",
#'   "2022-08-20T00:00:00Z",
#'   "2022-08-21T00:00:00Z"
#' )
#'
#' # Specify the time range using POSIXct objects, and set the optional "step"
#' query_range(
#'   "rate(http_requests_total[5m])",
#'   Sys.time() - (60 * 60 * 24),
#'   Sys.time(),
#'   step = "30s"
#' )
#'
#' # Specify the time range using unix timestamps, and set an optional "timeout"
#' query_range(
#'   "rate(http_requests_total[5m])",
#'   1660989814,
#'   1661076214,
#'   timeout = "60s"
#' )
#' }
#' @export
query_range <- function(query,
                        start,
                        end,
                        host = "http://127.0.0.1:9090",
                        step = "10s",
                        timeout = NA) {
  # Construct the v1 API query URL
  url <- build_url(host, query, start, end, step, timeout) # nolint.

  # Send the request and validate it succeeded
  r <- httr::GET(url)
  if (r$status_code != 200) {
    stop("bad response code ", r$status_code, ":", r$error)
  }

  # Parse the JSON response.
  d <- httr::content(r, "parsed")
  if (d$data$resultType != "matrix") {
    stop("unexpected result type ", d$data$resultType)
  }

  # Populate the output tibble
  df <- tibble::tibble()
  for (r in d$data$result) {
    # Capture the name + labels
    row <- tibble::as_tibble(r$metric)

    # Compute the number of measurements in the tuple list
    values <- unlist(r$value)
    n_rows <- length(values) / 2

    # Construct a tibble of values by first unrolling the list, and then turning
    # it into a matrix, populated row wise.
    values <- tibble::as_tibble(
      matrix(
        values,
        ncol = 2,
        nrow = n_rows,
        byrow = TRUE
      ),
      .name_repair = ~ c("timestamp", "value")
    )

    # Convert the string values into useful types
    values$timestamp <- as.POSIXct(
      as.numeric(values$timestamp),
      origin = "1970-01-01"
    )
    values$value <- as.numeric(values$value)

    # Nest the values tibble in the output row
    row$values <- list(values)

    # Add this metric to the output
    df <- rbind(df, row)
  }

  return(df)
}
