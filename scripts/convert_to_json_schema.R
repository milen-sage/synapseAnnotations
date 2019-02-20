######################################################################
####  Convert annotations controlled vocabularies to JSON schema  ####
######################################################################

library("purrr")
library("rlang")
library("jsonlite")

## Convert our enumerated values objects with description etc. into schema
## objects (with value as "const" and additional properties for description and
## source)
create_enum <- function(list) {
  list(const = list$value, description = list$description, source = list$source)
}

## Given an annotation entry, convert it to JSON Schema format
create_schema_from_entry <- function(x) {
  desc <- x$description %||% ""
  if (length(x$enumValues) > 0) {
    ## If there are enum values, turn those into objects using `"const"` so we
    ## can attach description and source as well
    enum <- purrr::map(x$enumValues, create_enum)
    ret <- list(
      name = list(
        description = desc,
        anyOf = enum
      )
    )
  } else if (!is.null(x$columnType)) {
    ## Some annotations just have a column type; in that case set this to "type"
    ret <- list(
      name = list(
        description = desc,
        type = switch(
          x$columnType,
          "STRING" = "string",
          "BOOLEAN" = "boolean",
          "INTEGER" = "integer",
          "DOUBLE" = "number"
        )
      )
    )
  }
  names(ret) <- x$name
  ret
}

## Given a set of entries (e.g. one file from our synapseAnnotations/data/
## folder), create a set of definitions
create_schema_from_entries <- function(x) {
  map(x, create_schema_from_entry) %>%
    unlist(recursive = FALSE)
}

## Add additional JSON Schema stuff and convert to JSON
create_output_json <- function(definitions) {
  list(
    "$schema" = "http://json-schema.org/draft-07/schema#",
    "$id" = "http://example.com/definitions.json",
    "definitions" = definitions
  ) %>%
    toJSON(auto_unbox = TRUE, pretty = TRUE)
}

## Convert sageCommunity and experimentalData json
test_files <- list.files(
  "../synapseAnnotations/data",
  pattern = "sageCommunity|experimentalData",
  full.names = TRUE
)
names(test_files) <- basename(test_files)

test_data <- test_files %>%
  map(read_json, simplifyVector = FALSE) %>%
  map(create_schema_from_entries) %>%
  map(create_output_json)

iwalk(
  test_data,
  function(x, y) write(x, paste0("../synapseAnnotations/schemas/", y))
)
