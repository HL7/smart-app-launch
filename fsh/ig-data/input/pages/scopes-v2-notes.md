
# Draft API Additions for SMART Scopes v2 (work in progress)

This documentation captures API design plans as of August 2020, as a target for the Granular Data track at the FHIR September 2020 Connectathon.

## Finer-grained interaction constraints using `.cruds`

In SMART 1.0, scopes ended in `.read`, `.write`, or `.*`. For SMART 2.0, we provide more detailed suffixes to convey support for the following FHIR REST API interactions:

* `c` for `create`
* `r` for `read` and `vread`
* `u` for `update`
* `d` for `delete`
* `s` for `search`

Valid suffixes are a subset of the string `.cruds`. For example, to convey support for creating and updating observations, use scope `patient/Observation.cu`. To convey support for reading and searching observations, use scope `patient/Observation.rs`. For backwards compatibility, servers should tread SMART v1 scopes as follows:

* `.read` ⇒ `.rs`
* `.write` ⇒ `.cud`
* `.*` ⇒ `.cruds`


## Finer-grained resource constraints using search parameters

In SMART 1.0, scopes were based entirely on FHIR Resource types, as in `patient/Observation.read` (for Observations) or `patient.Immunization.read` (for Immunizations). In SMART 2.0, we provide more detailed constraints based on FHIR REST API search parameter syntax. To apply these constraints, add a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value` items separated by `&`. For example, to request read and search access to laboratory observations but not other observations, the scope `patient/Observation.rs?category=laboratory`.

Note: While the search parameter based syntax here is quite general, and could be used for any search parameter defined in FHIR, we're seeking community consensus on a small common core of search parameters for broad support. As such, we'll be focused on:

* `_tag` for all resource types
* `_security` for all resource types
* `category` for resource types where a category or type exists (e.g., Observation, Condition)


----

# Historical notes...

## Placeholder for SMART Scopes v2 (work in progress)

"sub-resource scopes"
* `category` for resource

## Placeholder for SMART Scopes v2 (work in progress)

"sub-resource scopes"

Human-centric scopes like:

* contact info
* work history
* addiction/social hx
* sexual hx
* mental health
* genomics

In practice, applying these labels an guaranteeing their accuracy is an unsolved research problem, though there are promising approaches.

---

Functional requirements:

* All resources with a specific tag
* All resources without a specific tag
* Observations by category
* Conditions by category
* DiagnosticReport
* DocuemntReference
* Any Resource with a category by categry

## So the basic data model is

* Scoping context: patient|user|system
* Resource type: Observation
* Allowed Category: http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* Interaction: read|create|update|delete|?search


Notes
* category is near-term, low-hanging, practical
* tag is outlet / forward-looking opportunity for more sophisticated behaviors, even if there's not widely supportefd automatic labeling deployed today

## Looking at syntaxes


```
patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#laboratory.read
{"context": "patient","resourceType": "Observation", "category": "http://terminology.hl7.org/CodeSystem/observation-category#laboratory", "interaction": "read"}

patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#social-history.read
{"context": "patient","resourceType": "Observation", "category": "http://terminology.hl7.org/CodeSystem/observation-category#social-history", "interaction": "read"}

patient/Observation:http://terminology.hl7.org/CodeSystem/observation-category#exam.read
{"context":"patient","resourceType":"Observation","category":"http://terminology.hl7.org/CodeSystem/observation-category#exam","interaction":"read"}
```

These are long... especially if you have a lot of them. But each one is straightforward, at least. Each one can be treated independently (i.e., they're OR'd together).

Still, this quickly starts to suggests a combined syntax like:

```js
[{
  "context": "patient",
  "resourceType": ["Observation"],
  "interaction": ["read", "search", "create", "update"],
  "category": [
    "#laboratory",
    "#vital-signs",
    "#social-history",
  ]
  "tagRequired": [],
  "tagExcluded": [],
  "securityLabelRequired": []
  "securityLabelExcluded": ["http://terminology.hl7.org/CodeSystem/v3-Confidentiality Code Display#V"]
}]
```
