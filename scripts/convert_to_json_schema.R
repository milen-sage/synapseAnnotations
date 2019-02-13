######################################################################
####  Convert annotations controlled vocabularies to JSON schema  ####
######################################################################

library("purrr")
library("rlang")

## Convert our enumerated values objects with description etc. into schema
## objects (with value as "const" and additional properties for description and
## source)
create_enum <- function(list) {
  list(const = list$value, description = list$description, source = list$source)
}

## Given an annotation entry, convert it to JSON Schema format
create_schema_from_entry <- function(x) {
  name <- x$name
  desc <- x$description %||% ""
  if (!is.null(x$enumValues)) {
    enum <- purrr::map(x$enumValues, create_enum)
    ret <- list(
      name = list(
        description = desc,
        anyOf = enum
      )
    )
  } else if (!is.null(x$columnType)) {
    ret <- list(
      name = list(
        description = desc,
        type = x$columnType
      )
    )
  }
  names(ret) <- name
  ret
}

sage_comm <- read_json(
  "../synapseAnnotations/data/sageCommunity.json",
  simplifyVector = FALSE
)

definitions <- map(sage_comm, create_schema_from_entry) %>%
  unlist(recursive = FALSE)

output_json <- list(
    "$schema" = "http://json-schema.org/draft-07/schema#",
    "$id" = "http://example.com/definitions.json",
    "definitions" = definitions
  ) %>%
  toJSON(auto_unbox = TRUE, pretty = TRUE)

write(output_json, "../synapseAnnotations/schemas/definitions.json")
