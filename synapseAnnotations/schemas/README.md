# Schemas

Schemas in JSON Schema format. These are translated from the files in `../data/`
by the `convert_to_json_schema.R` script. To check that they are valid:

```
ajv compile -s "*.json"
```
