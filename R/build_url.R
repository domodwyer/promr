#' Construct a URL for the specified query.
#'
#' @param base A hostname and schema to base the generated path off of.
#' @param query A PromQL query.
#' @param start A RFC3339 timestamp string, numerical unix timestamp, or POSIXct
#'     object.
#' @param end A RFC3339 timestamp string, numerical unix timestamp, or POSIXct
#'     object.
#' @param step A query resolution step width.
#' @param timeout An optional query timeout value, defaulting to server-side
#'     limit. Note this timeout is capped to the server-side value.
#' @return A URL to execute the query.
build_url <- function(base, query, start, end, step, timeout = NA) {
    url <- urltools::url_parse(base)
    url$path <- "api/v1/query_range"

    url <- urltools::url_compose(url) |>
        urltools::param_set(
            key = "query",
            value = urltools::url_encode(query)
        ) |>
        urltools::param_set(
            key = "start",
            value = cast_timestamp(start)
        ) |>
        urltools::param_set(
            key = "end",
            value = cast_timestamp(end)
        ) |>
        urltools::param_set(
            key = "step",
            value = step
        )

    if (!is.na(timeout)) {
        url <- urltools::param_set(url, key = "timeout", value = timeout)
    }

    return(url)
}

#' A helper function to map an input of various types to a timestamp string
#' suitable for use with Prometheus.
#'
#' @param input A RFC3339 timestamp string, numerical unix timestamp, or POSIXct
#'     object.
#' @return A Prometheus-compatible timestamp that can be coerced to a string.
cast_timestamp <- function(input) {
    out <- switch(typeof(input),
        "character" = input,
        "double" = input,
        NULL
    )
    if (!is.null(out)) {
        return(out)
    }
    if (inherits(input, "POSIXt")) {
        return(as.numeric(input))
    }
    stop("unknown timestamp type")
}
