### `smart-app-state` capability

This experimental capability allows apps to persist a small amount of
configuration data to an EHR's FHIR server. Conformance requirements described
below apply only to software that implements support for this capability.
Example use cases include:

* An app with no backend storage persists user preferences such as default
  screens, shortcuts, or color preferences. Such apps can save preferences to
  the EHR and retrieve them on subsequent launches.

* An app maintains encrypted external data sets. Such apps can persist access keys
  to the EHR and retrieve them on subsequent launches, allowing in-app
  decryption and display of external data sets.

**Apps SHALL NOT use `smart-app-state` when the data being persisted could be
managed directly using FHIR domain models.** For example, an app would never
persist clinical diagnoses or observations using `smart-app-state`. Such usage
is prohibited because the standard FHIR API provides safer and more
interoperable mechanisms for clinical data sharing.

**Apps SHALL NOT expect the EHR to use or interpret data stored via
`smart-app-state`**  unless specific agreements are made outside the scope of
this capability.

<a id="at-most-one-subject"></a>
Note that while state can be associated with a user account or with a patient
record, this capability does not enable state associated with (user, patient)
pairs. For instance, there is no defined mechanism to save information like
"Practitioner A prefers her diabetes management app to start with the 'recent
labs' screen for Patient A, and the 'in-range glucose time' screen for Patient
B."

### Formal definitions

The narrative documentation below provides formal requirements, usage notes, and examples.

In addition, the following conformance resources can support automated processing in FHIR R4:

* [CapabilityStatement/smart-app-state-server](CapabilityStatement-smart-app-state-server.html)
* [StructureDefinition/smart-app-state-basic](StructureDefinition-smart-app-state-basic.html)

### Discovery

EHRs supporting this capability SHALL advertise support by including
`"smart-app-state"` in the capabilities array of their FHIR server's
`.well-known/smart-configuration` file (see section [Conformance](conformance.html)).

EHRs MAY include an `associated_endpoints[]` entry if they want to maintain App State management functionality at a
location distinct form the core EHR's FHIR endpoint (see section [Design
Notes](#design-notes)).

#### Example discovery document

Consider a FHIR server with base URL `https://ehr.example.org/fhir`.

If state is directly managed by the FHIR server, the discovery document at
`https://ehr.example.org/fhir/.well-known/smart-configuration` might include:

```js
{
  "capabilities": [
    "smart-app-state",
    // <other capabilities snipped>
  ],
  // <other properties snipped>
}
```

If state is externally managed, the discovery document might include:

```js
{
  "associated_endpoints": [{
    "url": "https://ehr.example.org/appstate",
    "capabilities": ["smart-app-state"]
  }]
  // <other properties snipped>
}
```


### App State Interactions

The EHR's App State FHIR endpoint SHALL provide support for:

2. `POST /Basic`
2. `PUT /Basic/[id]` requiring the presence of `If-Match` to prevent contention
2. `DELETE /Basic/[id]` requiring the presence of `If-Match` to prevent contention
1. `GET /Basic?code={}&subject={}`
1. `GET /Basic?code={}&subject:missing=true` // for global app config

The semantics of these FHIR API interactions are defined in the [core FHIR
specification](https://hl7.org/fhir/http.html). In the case of discrepancies,
the core specification takes precedence.

This specification does not impose additional requirements on the App State FHIR endpoint.


### Managing app state (CRUDS)

App State data can include details like encryption keys. EHRs SHALL evaluate
storage requirements and MAY store App State data separately from their routine
FHIR Resource storage space. 

App State is always associated with a "state code" (`Basic.code.coding`) and
optionally associated with a subject (`Basic.subject`).

EHRs SHALL allow at least one `smart-app-state` resource per state code, and at
least one `smart-app-state` resource per (state code, subject) tuple. EHRs
SHOULD describe applicable limits in their developer documentation.

EHRs SHOULD retain app state data for as long as the originating app remains
actively registered with the EHR. EHRs MAY establish additional retention
policies in their developer documentation.

#### Create

To create app state, an app submits to the EHR's App State endpoint:

    POST /Basic

The request body is a `Basic` resource where:

1. Total resource size as serialized in the POST body SHALL NOT exceed 256KB unless the EHR's documentation establishes a higher limit
2. `Basic.id` SHALL NOT be included
2. `Basic.meta.versionId` SHALL NOT be included
3. `Basic.subject.reference` is optional, associating App State with <a href="#at-most-one-subject">at most one subject</a>. When omitted, global configuration can be stored in App State. When present, this SHALL be an absolute reference to a resource in the EHR's primary FHIR server. The EHR SHALL support at least Patient, Practitioner, PractitionerRole, RelatedPerson, Person. The EHR's documentation MAY establish support for a broader set of resources.
5. `Basic.code.coding[]`  SHALL include exactly one app-specified Coding
6. `Basic.extension` Extensions SHALL be limited to the `valueString` type unless the EHR's documentation establishes a broader set of allowed extension types

If the EHR accepts the request, the EHR SHALL persist the submitted resource including:

* a newly generated server-side unique value in populated in `Basic.id`
* a value populated in `Basic.meta.versionId`
* the Reference present in `Basic.subject`, if any
* the Coding present in `Basic.code.coding`
* all top-level extensions present in the request

If the EHR cannot meet all of these obligations, it SHALL reject the request.

The response headers include an `ETag` header following [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The response body is a `Basic` resource representing the state persisted by the EHR.

#### Updates

To update app state, an app submits to the EHR's App State endpoint:

    PUT /Basic/[id]

The request SHALL include an `If-Match` header with an ETag to prevent
contention as defined in [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The payload is a `Basic` resource where:

1. `Basic.id` SHALL be present, matching the `[id]` in the request URL
3. `Basic.subject` and `Basic.code` SHALL NOT change from the previously-persisted values

EHR servers SHALL return a `412 Precondition Failed` response if the version
specified in `If-Match` header's ETag does not reflect the most recent version
stored in the server, or if the `Basic.subject` or `Basic.code` does not match
previously-persisted value.

The successful response headers include an `ETag` header following [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

The response body is a `Basic` resource representing the state persisted by the EHR.

#### Deletes

To delete app state, an app submits to the EHR's App State endpoint:

    DELETE /Basic/[id]

The request SHALL include an `If-Match` header with an ETag to prevent
contention as defined in [FHIR Core "Managing Resource
Contention"](https://hl7.org/fhir/http.html#concurrency).

EHR servers SHALL return a `412 Precondition Failed` response if the version
specified in `If-Match` header's ETag does not reflect the most recent version
stored in the server.

After successfully deleting state, an app SHALL NOT submit subsequent requests
to modify the same state by `Basic.id`. Servers SHALL process any subsequent
requests about this `Basic.id` as a failed precondition.


#### Querying app state

An app SHALL query for state by supplying a state type code and optionally a
subject:

* `GET /Basic?code={}&subject={}` for state associated with a specific subject
* `GET /Basic?code={}&subject:missing=true` for global state associated with the app overall

The EHR SHALL support the following query parameters:

* `?code` , restricted to fixed state codes that exactly match `Basic.code.coding[0]` (i.e., `${system}` + `|` + `${code}`)
* `?subject`, restricted to absolute references that exactly match `Basic.subject.reference`, with support for the `:missing=true` modifier to find global state

The response body is a FHIR Bundle where each entry is a `Basic` resource as persisted by the EHR.

The EHR MAY support additional queries, and an app MAY issue additional queries when they are supported.

### API Examples

#### Example 1: App-specific User Preferences

The following example `POST` body shows how an app might persist a user's app-specific preferences:

```
POST /Basic

Authorization: Bearer <snipped>
```
```js
{
  "resourceType": "Basic",
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  "code": {
    "coding": [
      // app-specific designation; the EHR does not need to understand
      // the meaning of this concept, but SHALL persist it and MAY
      // use it for access control (e.g., using SMART on FHIR scopes
      // or other controls; see below)
      { 
        "system": "https://myapp.example.org",
        "code": "display-preferences"
      }
    ]
  },
  "extension": [
    // app-managed state; the EHR does not need to understand
    // the meaning of these values, but SHALL persist them
    {
      "url": "https://myapp.example.org/display-preferences-v2.0.1",
      "valueString": "{\"defaultView\":\"problem-list\",\"colorblindMode\":\"D\",\"resultsPerPage\":150}"
    }
  ]
}
```

The API response populates `id` and `meta.versionId`, like:

```
Location: https://ehr.example.org/appstate/Basic/1000
ETag: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1000",
  "meta": {"versionId": "a"},
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  ...<snipped for brevity>
```

To query for these data, an app could invoke the following operation (newlines added for clarity):

```
GET /Basic
  subject=https://ehr.example.org/fhir/Practitioner/123&
  code=https://myapp.example.org|display-preferences

Authorization: Bearer <snipped>
```

... which returns a Bundle including the "Example 1" payload.

#### Example 2: Access Keys to an external data set

The following `POST` body shows how an app might persist access keys for an externally managed encrypted data set:

```
POST /Basic

Authorization: Bearer <snipped>
```

```js
{
  "resourceType": "Basic",
  "subject": {"reference": "https://ehr.example.org/fhir/Patient/123"},
  "code": {
    "coding": [
      // app-specific designation; the EHR does not need to understand
      // the meaning of this concept, but SHALL persist it and MAY
      // use it for access control (e.g., using SMART on FHIR scopes
      // or other controls; see below)
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  },
  "extension": [
    // app-managed state; the EHR does not need to understand
    // the meaning of these values, but SHALL persist them
    {
      "url": "https://myapp.example.org/encrypted-phr-access-keys",
      "valueString": "eyJhbGciOiJSU0EtT0FFUCIsImVuYyI6IkEyNTZH...<snipped>"
    }
  ]
}
```

The EHR responds with a Basic resource representing the new SMART App State
object as it has been persisted. The API response populates `id` and
`meta.versionId`, like:

```
Location: https://ehr.example.org/appstate/Basic/1001
ETag: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "meta": {"versionId": "a"},
  "subject": {"reference": "https://ehr.example.org/fhir/Practitioner/123"},
  ...<snipped for brevity>
```

#### Example 3: Updating the Access Keys from Example 2

The following `POST` body shows how an app might update persisted access keys for an externally managed encrypted data set, based on the response to Example 2.


```
PUT /Basic/1001

Authorization: Bearer <snipped>
If-Match: W/"a"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "subject": {"reference": "https://ehr.example.org/fhir/Patient/123"},
  "code": {
    "coding": [
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  },
  "extension": [
    {
      "url": "https://myapp.example.org/encrypted-phr-access-keys",
      "valueString": "eyJhbGc<updated value, snipped>"
    }
  ]
}
```

The EHR responds with a Basic resource representing the updated SMART App State object as it has been persisted. The API response includes an updated `meta.versionId`, like:

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "meta": {"versionId": "b"},
  ...<snipped for brevity>
```


#### Example 4: Deleting the Access Keys from Example 3

The following `POST` body shows how an app might delete persisted access keys for an externally managed encrypted data set, based on the response to Example 3.


```
DELETE /Basic/1001

Authorization: Bearer <snipped>
If-Match: W/"b"
```

```js
{
  "resourceType": "Basic",
  "id": "1001",
  "subject": {"reference": "Patient/123"},
  "code": {
    "coding": [
      { 
        "system": "https://myapp.example.org",
        "code": "encrypted-phr-access-keys"
      }
    ]
  }
}
```

The EHR responds with a `200 OK` or `204 No Content` message to indicate a successful deletion.

### Security and Access controls


Apps SHALL NOT use data from `Extension.valueString` without validating or
sanitizing the data first. In other words, app developers need to consider a
threat model where App State values have been populated with arbitrary content.
(Note that EHRs are expected to simply store and return such data unmodified,
without "using" the data.)

The EHR SHALL enforce access controls to ensure that only authorized apps are
able to perform the FHIR interactions described above. From the app's
perspective, these operations are invoked using a SMART on FHIR access token in
an Authorization header. Every App State request SHALL include an Authorization
header with an access token issued by the EHR's authorization server. 

This means the EHR tracks (e.g., in some internal, implementation-specific
format) sets of `Coding`s representing the SMART App State types (i.e.,
`Basic.code.coding`) that the app is allowed to

  * query, when the subject is the in-context patient
  * modify, when the subject is the in-context patient
  * query, when the subject is the in-context app user
  * modify, when the subject is the in-context app user
  * query, with `subject:missing=true` (for global app config)
  * modify, with `subject:missing=true` (for global app config)

EHRs SHALL only associate state codes with an app if the app is trusted to access
those data. These decisions can be made out-of-band during or after the app
registration process. A recommended default is to allow apps to register only
state codes where the `system` matches the app's verified origin. For instance,
if the EHR has verified that the app developer manages the origin
`https://app.example.org`, the app could be associated with SMART App State
types like `https://app.example.org|user-preferences` or
`https://app.example.org|phr-keys`. If an app requires access to other App
State types, these could be reviewed through an out-of-band process. This
situation is expected when one developer supplies a patient-facing app and
another developer supplies a provider-facing "companion app" that needs to
query the state written by the patient-facing app.

Further consideration is required when granting an app the ability to modify
global app state (i.e., where `Basic.subject` is absent). Such permissions
should be limited to administrative apps. See section [global app
configuration](#global-app-configuration).

Where appropriate, the EHR MAY expose these controls using SMART scopes as follows.

#### Granting access at the user level

An app writing user-specific state (e.g., user preferences) or writing patient-specific state on behalf of an authorized user can request SMART scopes like:

    user/Basic.cuds // query and modify state

This scope would allow the app to manage any app state that the user is permitted to manage. Note that without further refinement, this scope could allow an app to see and manage app state from *other apps* in addition to its own. This can be a useful behavior in scenarios where sets of apps have a mutual understanding of certain state values (e.g. a suite of apps offered by a single developer). 

#### Granting access at the patient level

An app writing patient-specific state (e.g., access keys for an externally managed encrypted data set) can request a SMART scope like:

    patient/Basic.cuds // query and modify state

This scope would allow the app to manage any app state that the user is
permitted to manage on the in-context patient record. Note that without further
refinement, this scope could allow an app to see and manage app state written
by *other apps*. This can be a useful behavior in scenarios where sets of apps
have a mutual understanding of certain state values (e.g., a patient-facing
mobile app that creates an encrypted data payload and a provider-facing
"companion app" that decrypts and displays the data set within the EHR). 

For the scenario of a patient-facing mobile app that works in tandem with
provider-facing "companion app" in the EHR, scopes can be narrowed to better
reflect minimum necessary access (note the use of more specific codes).

##### Patient-facing mobile app

    patient/Basic.cuds?code=https://myapp.example.org|encrypted-phr-access-keys

##### Provider-facing "companion app" in the EHR

    patient/Basic.s?code=https://myapp.example.org|encrypted-phr-access-keys

#### Global app configuration

Some apps might leverage "global" (i.e., hospital-wide) state stored in the
EHR. Such access could be requested for an administrative end-user with scopes
of the form:

    user/Basic.cuds // query and modify global app state
    user/Basic.s // query global app state

For example, a family of apps could be deployed with read access to a
"configuration" state type, with a management app authorized to modify this
state type. Using this pattern, a local site administrator could establish
settings across the family of apps.

A management app might create such hospital-defined configuration with:

    user/Basic.cuds?code=https://myapp.example.org|hospital-config

And the related family of apps installed at a hospital might access such
hospital-defined configuration with:

    user/Basic.s?code=https://myapp.example.org|hospital-config

#### Explaining access controls to end users

In the case of user-facing authorization interactions (e.g., for a
patient-facing SMART App), it's important to ensure that such scopes can be
explained in plain language. For example, it is important to explain to users
that any information their app submits to the EHR may be considered part of the
health record and may be accessible to their healthcare provider team. To
support authorization, EHRs may need to gather additional information from app
developers at registration time with explanations, or may apply additional
protections to facilitate access control decisions. 

#### Implementation considerations for EHRs

EHRs can implement support for `smart-app-state` using their internal resource
server infrastructure, or can deploy a decoupled resource server that
communicates with the EHR authorization server using [SMART on FHIR Token
Introspection](token-introspection.html), signed tokens, or some other
mechanism. While some access control decisions can be made directly based on
standardized scopes, other decisions may require additional policy information.
See ["scopes are used to delegate
access"](scopes-and-launch-context.html#smarts-scopes-are-used-to-delegate-access)
for background on this point.

Consider the following examples:

* a token granting `patient/Basic.s?code=https://app|1` with a context of
  `"patient": "a"` would be authorized to query
  `Basic?subject=Patient/a&code=https://app|1`

* a token granting `user/Basic.s?code=https://app|1` with a context of
  `"fhirUser": "Practitioner/b"` would be authorized to query
  `Basic?subject=Practitioner/b&code=https://app|1`

* a token granting `user/Basic.s?code=https://app|1` with no patient context
  and a user context of `"fhirUser": "Practitioner/b"` would require additional
  policy information to decide whether to allow
  `Basic?subject=Patient/a&code=https://app|1`. A server MAY simply reject
  queries like this as unauthorized, while still supporting many use cases. To
  properly authorize this request, a resource server would need to determine
  whether EHR policy allows Practitioner B to access Patient A's records. Such
  policy information could be static (e.g., a simple system could maintain a
  policy like "all Practitioner users can access all patient records") or
  dynamically available in EHR-specific ways such as FHIR Groups, CareTeams,
  PractitionerRoles, or non-FHIR APIs such as
  [SCIM](https://www.simplecloud.info/) or others. Such policy details are
  beyond the scope of SMART on FHIR.

### Design Notes

Implementers may wonder why the SMART App State capability defines a FHIR Base
URL that might be distinct from the EHR's main FHIR base URL. During the design
and prototype phase, implementers identified requirements that led to this
design:

* Ensure that EHRs can identify App State requests via path-based HTTP request
  evaluation. This allows EHRs to route App State requests to a purpose-built
  underlying service. Such identification is not possible when the only path
  information is `/Basic` (e.g., for `POST /Basic` on the EHR's main FHIR
  endpoint), since non-App-State CRUD operations on `Basic` would use this same
  path. Providing the option for a distinct FHIR base URL allows EHRs to
  establish predictable and distinct paths when this is desirable.

* Ensure that App State can be persisted separately from other `Basic`
  resources managed by the EHR. This stems from the fact that App State is
  essentially opaque to the EHR and should not be returned in general-purpose
  queries for `Basic` content (which may be used to surface first-class EHR
  concepts).
