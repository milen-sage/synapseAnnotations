# Definitions

Schemas in JSON Schema format. These are translated from the files in `../data/`
by the `convert_to_json_schema.R` script and can be reused in other schemas. To
check that they are valid using [https://github.com/jessedc/ajv-cli](ajv-cli):

```
ajv compile -s "*.json"
```
