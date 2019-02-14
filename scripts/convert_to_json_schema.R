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
  if (!is.null(x$enumValues)) {
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
        type = x$columnType
      )
    )
  }
  names(ret) <- x$name
  ret
}

## Load sageCommunity json to test with
sage_comm <- read_json(
  "../synapseAnnotations/data/sageCommunity.json",
  simplifyVector = FALSE
)

## Create definitions
definitions <- map(sage_comm, create_schema_from_entry) %>%
  unlist(recursive = FALSE)

## Add additional JSON Schema stuff and convert to JSON
output_json <- list(
    "$schema" = "http://json-schema.org/draft-07/schema#",
    "$id" = "http://example.com/definitions.json",
    "definitions" = definitions
  ) %>%
  toJSON(auto_unbox = TRUE, pretty = TRUE)

write(output_json, "../synapseAnnotations/schemas/definitions.json")
