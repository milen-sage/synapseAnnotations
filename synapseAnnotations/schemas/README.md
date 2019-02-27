# Schemas

An example schema for AMP-AD. It references the definitions in the
`definitions/` folder. To check that the schema is valid JSON Schema:

```
ajv compile -s ampad_schema.json -r "definitions/*.json"
```

To validate sample data against the AMP-AD schema:

```
ajv -s ampad_schema.json -r "definitions/*.json" -d ampad_demo.json
```
