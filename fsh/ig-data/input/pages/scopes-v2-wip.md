
## Draft API Additions for SMART Scopes v2 (work in progress)

This documentation captures API design plans as of August 2020, as a target for the Granular Data track at the FHIR September 2020 Connectathon.

### Finer-grained interaction constraints using `.cruds`

In SMART 1.0, scopes ended in `.read`, `.write`, or `.*`. For SMART 2.0, we provide more detailed suffixes to convey support for the following FHIR REST API interactions:

* `c` for `create`
  * Type level [create](http://hl7.org/fhir/http.html#create)
* `r` for `read`
  * Instance level [read](http://hl7.org/fhir/http.html#read)
  * Instance level [vread](http://hl7.org/fhir/http.html#vread)
  * Instance level [history](http://hl7.org/fhir/http.html#history)
* `u` for `update`
  * Instance level [update](http://hl7.org/fhir/http.html#update)
    Note that some servers allow for an [update operation to create a new instance](http://hl7.org/fhir/http.html#upsert)
  * Instance level [patch](http://hl7.org/fhir/http.html#patch)
* `d` for `delete`
  * Instance level [delete](http://hl7.org/fhir/http.html#delete)
* `s` for `search`
  * Type level [search](http://hl7.org/fhir/http.html#search)
  * Type level [history](http://hl7.org/fhir/http.html#history)
  * System level [search](http://hl7.org/fhir/http.html#search)
  * System level [history](http://hl7.org/fhir/http.html#history)

Valid suffixes are a subset of the in-order string `.cruds`. For example, to convey support for creating and updating observations, use scope `patient/Observation.cu`. To convey support for reading and searching observations, use scope `patient/Observation.rs`. For backwards compatibility, servers should tread SMART v1 scopes as follows:

* `.read` ⇒ `.rs`
* `.write` ⇒ `.cud`
* `.*` ⇒ `.cruds`

Scope requests with undefined or out of order interactions MAY be ignored, replaced with server default scopes, or rejected. For example, a request of `.dus` is not a defined scope request. This policy is to prevent misinterpretation of scopes with other conventions (e.g., interpreting `.read` as `.rd` and granting extraneous delete permissions).

### Batches and Transactions

SMART 2.0 does not define specific scopes for [batch or transaction](http://hl7.org/fhir/http.html#transaction) interactions. These system-level interactions are simply convience wrappers for other interactions. As such, batch and transaction requests should be validated based on the actual requests within them.

### Scope Equivalence

Multiple scopes compounded or expanded are equivalent to each other.  E.g., `Observation.rs` is interchangeable with `Observation.r Observation.s`. In order to reduce token size, it is recomended that scopes be factored to their shortest form.

Note that multiple requests for the same scope MAY be ignored or rejected.

### Finer-grained resource constraints using search parameters

In SMART 1.0, scopes were based entirely on FHIR Resource types, as in `patient/Observation.read` (for Observations) or `patient.Immunization.read` (for Immunizations). In SMART 2.0, we provide more detailed constraints based on FHIR REST API search parameter syntax. To apply these constraints, add a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value` items separated by `&`. For example, to request read and search access to laboratory observations but not other observations, the scope `patient/Observation.rs?category=laboratory`.

Note: While the search parameter based syntax here is quite general, and could be used for any search parameter defined in FHIR, we're seeking community consensus on a small common core of search parameters for broad support. As such, we'll be focused on:

* `_tag` for all resource types
* `_security` for all resource types
* `category` for resource types where a category or type exists (e.g., Observation, Condition)

----

## Historical notes...

### Placeholder for SMART Scopes v2 (work in progress)

"sub-resource scopes"
* `category` for resource

### Placeholder for SMART Scopes v2 (work in progress)

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

### So the basic data model is

* Scoping context: patient|user|system
* Resource type: Observation
* Allowed Category: http://terminology.hl7.org/CodeSystem/observation-category#laboratory
* Interaction: read|create|update|delete|?search


Notes
* category is near-term, low-hanging, practical
* tag is outlet / forward-looking opportunity for more sophisticated behaviors, even if there's not widely supportefd automatic labeling deployed today

### Looking at syntaxes


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
