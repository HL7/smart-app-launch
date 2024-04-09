SMART on FHIR's authorization scheme uses OAuth scopes to communicate (and
negotiate) access requirements. Providing apps with access to broad data sets is consistent with current common practices (e.g., interface engines also provide access to broad data sets); access is also limited based on the privileges of the user in context.  In general, we use scopes for three kinds of data:

1. [FHIR Resources](#scopes-for-requesting-fhir-resources)
1. [Contextual data](#scopes-for-requesting-context-data)
1. [Identity data](#scopes-for-requesting-identity-data)

Launch context is a negotiation where a client asks for specific launch context
parameters (e.g., `launch/patient`). A server can decide which launch context
parameters to provide, using the client's request as an input into the decision
process.  See ["scopes for requesting context data"](#scopes-for-requesting-context-data) for details.

### Quick Start

Here is a quick overview of the most commonly used scopes. The complete details are provided in the following sections.

Scope | Grants
------|--------
`patient/*.rs`    | Permission to read and search any resource for the current patient (see notes on wildcard scopes below).
`user/*.cruds`    | Permission to read and write all resources that the current user can access (see notes on wildcard scopes below).
`openid fhirUser` | Permission to retrieve information about the current logged-in user.
`launch`          | Permission to obtain launch context when app is launched from an EHR.
`launch/patient`  | When launching outside the EHR, ask for a patient to be selected at launch time.
`offline_access`  | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, even after the end-user no longer is online after the access token expires.
`online_access`   | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.
{:.grid}

#### SMART's scopes are used to delegate access

SMART's scopes allow a client to request the delegation of a specific set of
access rights; such rights are always limited by underlying system policies and
permissions.

For example:

* If a client uses SMART App Launch to request `user/*.cruds` and is granted these scopes by a user, these scopes convey "full access" relative to the user's underlying permissions.  If the underlying user has limited permissions, the client will face these same limitations.
* If a client uses SMART Backend Services to request `system/*.cruds`, these scopes convey "full access" relative to a server's pre-configured client-specific policy.  If the pre-configured policy imposes limited permissions, the client will face these same limitations.

Neither SMART on FHIR nor the FHIR Core specification provide a way to model
the "underlying" permissions at play here; this is a lower-level responsibility
in the access control stack.  As such, clients can attempt to perform FHIR
operations based on the scopes they are granted — but depending on the details
of the underlying permission system (e.g., the permissions of the approving
user and/or permissions assigned in a client-specific policy) these requests
may be rejected, or results may be omitted from responses.

For instance, a client may receive:

* `200 OK` response to a search interaction that appears to be allowed by the granted scopes, but where results have been omitted from the response Bundle.
* `403 Forbidden` response to a write interaction that appears to be allowed by the granted scopes.

Applications reading may receive results that have been filtered or redacted
based on the underlying permissions of the delegating authority, or may be
refused access (see guidance at [https://hl7.org/fhir/security.html#AccessDenied](https://hl7.org/fhir/security.html#AccessDenied)).

### Scopes for requesting FHIR Resources
<a id="scopes-for-requesting-clinical-data"></a>

SMART on FHIR defines OAuth2 access scopes that correspond directly to FHIR resource types. These scopes impact the access an application may have to FHIR resources (and actions). We define permissions to support the following FHIR REST API interactions:

* `c` for `create`
  * Type level [create](http://hl7.org/fhir/http.html#create)
* `r` for `read`
  * Instance level [read](http://hl7.org/fhir/http.html#read)
  * Instance level [vread](http://hl7.org/fhir/http.html#vread)
  * Instance level [history](http://hl7.org/fhir/http.html#history)
* `u` for `update`
  * Instance level [update](http://hl7.org/fhir/http.html#update)
    Note that some servers allow for an [update operation to create a new instance](http://hl7.org/fhir/http.html#upsert), and this is allowed by the update scope
  * Instance level [patch](http://hl7.org/fhir/http.html#patch)
* `d` for `delete`
  * Instance level [delete](http://hl7.org/fhir/http.html#delete)
* `s` for `search`
  * Type level [search](http://hl7.org/fhir/http.html#search)
  * Type level [history](http://hl7.org/fhir/http.html#history)
  * System level [search](http://hl7.org/fhir/http.html#search)
  * System level [history](http://hl7.org/fhir/http.html#history)


Valid suffixes are a subset of the in-order string `.cruds`. For example, to convey support for creating and updating observations, use scope `patient/Observation.cu`. To convey support for reading and searching observations, use scope `patient/Observation.rs`. For backwards compatibility with scopes defined in the SMART App Launch 1.0 specification, servers SHOULD advertise the `permission-v1` capability in their `.well-known/smart-configuration` discovery document, SHOULD return v1 scopes when v1 scopes are requested and granted, and SHOULD process v1 scopes with the following semantics in v2:

* v1 `.read` ⇒ v2 `.rs`
* v1 `.write` ⇒ v2 `.cud`
* v1 `.*` ⇒ v2 `.cruds`

Scope requests with undefined or out of order interactions MAY be ignored, replaced with server default scopes, or rejected. For example, a request of `.dus` is not a defined scope request. This policy is to prevent misinterpretation of scopes with other conventions (e.g., interpreting `.read` as `.rd` and granting extraneous delete permissions).

#### Batches and Transactions

SMART 2.0 does not define specific scopes for [batch or transaction](http://hl7.org/fhir/http.html#transaction) interactions. These system-level interactions are simply convenience wrappers for other interactions. As such, batch and transaction requests should be validated based on the actual requests within them.

#### Scope Equivalence

Scopes can be combined to represent a union of access. For example, "patient/Condition.rs patient/AllergyIntolerance.rs" expresses access to the Conditions and Allergies associated with the in-context patient. Similarly, "Observation.rs" expresses access equivalent to "Observation.r Observation.s". In order to reduce token size, it is recommended that scopes be factored to their shortest form.

#### Finer-grained resource constraints using search parameters

In SMART 1.0, scopes were based entirely on FHIR Resource types, as in `patient/Observation.read` (for Observations) or `patient/Immunization.read` (for Immunizations). In SMART 2.0, we provide more detailed constraints based on FHIR REST API search parameter syntax. To apply these constraints, add a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value` items separated by `&`. For example, to request read and search access to laboratory observations but not other observations, the scope `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|laboratory`.

#### Requirements for support

<div class="stu-note">
We’re seeking community consensus on a small common core of search parameters
for broad support; we reserve the right to make some search parameters
mandatory in the future.
</div>

#### Experimental features {%include exp.html%}
{%include exp-div.html%}
Because the search parameter based syntax here is quite general, it opens up the possibility of using many features that servers may have trouble supporting in a consistent and performant fashion. Given the current level of implementation experience, the following features should be considered experimental, even if they are supported by a server:

* Use of search modifiers such as `Observation.rs?code:in=http://valueset.example.org/ValueSet/diabetes-codes`
* Use of search parameter chaining such as `Observation.rs?patient.birthdate=1990`
* Use of [FHIR's `_filter` capabilities](https://www.hl7.org/fhir/search_filter.html)
</div>

#### Scope size over the wire

Scope strings appear over the wire at several points in an OAuth flow. Implementers should be aware that fine-grained controls can lead to a proliferation of scopes, increasing in the length of the `scope` string for app authorizations. As such, implementers should take care to avoid putting arbitrarily large scope strings in places where they might not "fit". The following considerations apply, presented in the sequential order of a SMART App Launch:

* When initiating an authorization request, app developers should prefer POST-based authorization requests to GET-based requests, since this avoids URL length limits that might apply to GET-based authorization requests. (For example, some current-generation browsers have a 32kB length limit for values displayed in the URL bar.)
* In the authorization code redirect response, no scopes are included, so these considerations do not apply.
* In the access token response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the token introspection response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the access token itself, implementation-specific considerations may apply. SMART leaves access token formats out of scope, so formally there are no restrictions. But since access tokens are included in HTTP headers, servers should take care to ensure they do not get too large. For example, some current-generation HTTP servers have an 8kB limit on header length. To remain under this limit, authorization servers that use structured token formats like JWT might consider embedding handles or pointers to scopes, rather than embedding literal scopes in an access token. Alternatively, authorization servers might establish an internal convention mapping shorter scope names into longer scopes (or common combinations of longer scopes).


#### FHIR Resource Scope Syntax

Expressed as a railroad diagram, the scope language is:

<svg class="railroad-diagram" width="1092" height="131" viewBox="0 0 1092 131">
<!--
https://github.com/tabatkins/railroad-diagrams
Diagram( Choice(0, 'patient', 'user', 'system'), Choice(0, '/'), Choice(0, 'FHIR Resource Type', '*'), Choice(0, '.'),  Optional('c'),  Optional('r'),  Optional('u'),  Optional('d'),  Optional('s'), Optional(Sequence('?', OneOrMore('param=value', '&'))))
-->
<style>
svg.railroad-diagram {
    background-color: hsl(30,20%,95%);
}
svg.railroad-diagram path {
    stroke-width: 3;
    stroke: black;
    fill: rgba(0,0,0,0);
}
svg.railroad-diagram text {
    font: bold 14px monospace;
    text-anchor: middle;
    white-space: pre;
}
svg.railroad-diagram text.diagram-text {
    font-size: 12px;
}
svg.railroad-diagram text.diagram-arrow {
    font-size: 16px;
}
svg.railroad-diagram text.label {
    text-anchor: start;
}
svg.railroad-diagram text.comment {
    font: italic 12px monospace;
}
svg.railroad-diagram g.non-terminal text {
    /*font-style: italic;*/
}
svg.railroad-diagram rect {
    stroke-width: 3;
    stroke: black;
    fill: hsl(120,100%,90%);
}
svg.railroad-diagram rect.group-box {
    stroke: gray;
    stroke-dasharray: 10 5;
    fill: none;
}
svg.railroad-diagram path.diagram-text {
    stroke-width: 3;
    stroke: black;
    fill: white;
    cursor: help;
}
svg.railroad-diagram g.diagram-text:hover path.diagram-text {
    fill: #eee;
}
</style>

<g transform="translate(.5 .5)">
<g>
<path d="M20 30v20m10 -20v20m-10 -10h20"></path>
</g>
<g>
<path d="M40 40h0"></path>
<path d="M156 40h0"></path>
<path d="M40 40h20"></path>
<g class="terminal ">
<path d="M60 40h0"></path>
<path d="M136 40h0"></path>
<rect x="60" y="29" width="76" height="22" rx="10" ry="10"></rect>
<text x="98" y="44">patient</text>
</g>
<path d="M136 40h20"></path>
<path d="M40 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 70h12"></path>
<path d="M124 70h12"></path>
<rect x="72" y="59" width="52" height="22" rx="10" ry="10"></rect>
<text x="98" y="74">user</text>
</g>
<path d="M136 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
<path d="M40 40a10 10 0 0 1 10 10v40a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 100h4"></path>
<path d="M132 100h4"></path>
<rect x="64" y="89" width="68" height="22" rx="10" ry="10"></rect>
<text x="98" y="104">system</text>
</g>
<path d="M136 100a10 10 0 0 0 10 -10v-40a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M156 40h0"></path>
<path d="M224 40h0"></path>
<path d="M156 40h20"></path>
<g class="terminal ">
<path d="M176 40h0"></path>
<path d="M204 40h0"></path>
<rect x="176" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="190" y="44">/</text>
</g>
<path d="M204 40h20"></path>
</g>
<g>
<path d="M224 40h0"></path>
<path d="M428 40h0"></path>
<path d="M224 40h20"></path>
<g class="terminal ">
<path d="M244 40h0"></path>
<path d="M408 40h0"></path>
<rect x="244" y="29" width="164" height="22" rx="10" ry="10"></rect>
<text x="326" y="44">FHIR Resource Type</text>
</g>
<path d="M408 40h20"></path>
<path d="M224 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M244 70h68"></path>
<path d="M340 70h68"></path>
<rect x="312" y="59" width="28" height="22" rx="10" ry="10"></rect>
<text x="326" y="74">&#42;</text>
</g>
<path d="M408 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M428 40h0"></path>
<path d="M496 40h0"></path>
<path d="M428 40h20"></path>
<g class="terminal ">
<path d="M448 40h0"></path>
<path d="M476 40h0"></path>
<rect x="448" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="462" y="44">.</text>
</g>
<path d="M476 40h20"></path>
</g>
<g>
<path d="M496 40h0"></path>
<path d="M564 40h0"></path>
<path d="M496 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M516 20h28"></path>
</g>
<path d="M544 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M496 40h20"></path>
<g class="terminal ">
<path d="M516 40h0"></path>
<path d="M544 40h0"></path>
<rect x="516" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="530" y="44">c</text>
</g>
<path d="M544 40h20"></path>
</g>
<g>
<path d="M564 40h0"></path>
<path d="M632 40h0"></path>
<path d="M564 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M584 20h28"></path>
</g>
<path d="M612 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M564 40h20"></path>
<g class="terminal ">
<path d="M584 40h0"></path>
<path d="M612 40h0"></path>
<rect x="584" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="598" y="44">r</text>
</g>
<path d="M612 40h20"></path>
</g>
<g>
<path d="M632 40h0"></path>
<path d="M700 40h0"></path>
<path d="M632 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M652 20h28"></path>
</g>
<path d="M680 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M632 40h20"></path>
<g class="terminal ">
<path d="M652 40h0"></path>
<path d="M680 40h0"></path>
<rect x="652" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="666" y="44">u</text>
</g>
<path d="M680 40h20"></path>
</g>
<g>
<path d="M700 40h0"></path>
<path d="M768 40h0"></path>
<path d="M700 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M720 20h28"></path>
</g>
<path d="M748 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M700 40h20"></path>
<g class="terminal ">
<path d="M720 40h0"></path>
<path d="M748 40h0"></path>
<rect x="720" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="734" y="44">d</text>
</g>
<path d="M748 40h20"></path>
</g>
<g>
<path d="M768 40h0"></path>
<path d="M836 40h0"></path>
<path d="M768 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M788 20h28"></path>
</g>
<path d="M816 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M768 40h20"></path>
<g class="terminal ">
<path d="M788 40h0"></path>
<path d="M816 40h0"></path>
<rect x="788" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="802" y="44">s</text>
</g>
<path d="M816 40h20"></path>
</g>
<g>
<path d="M836 40h0"></path>
<path d="M1052 40h0"></path>
<path d="M836 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M856 20h176"></path>
</g>
<path d="M1032 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M836 40h20"></path>
<g>
<path d="M856 40h0"></path>
<path d="M1032 40h0"></path>
<g class="terminal ">
<path d="M856 40h0"></path>
<path d="M884 40h0"></path>
<rect x="856" y="29" width="28" height="22" rx="10" ry="10"></rect>
<text x="870" y="44">?</text>
</g>
<path d="M884 40h10"></path>
<path d="M894 40h10"></path>
<g>
<path d="M904 40h0"></path>
<path d="M1032 40h0"></path>
<path d="M904 40h10"></path>
<g class="terminal ">
<path d="M914 40h0"></path>
<path d="M1022 40h0"></path>
<rect x="914" y="29" width="108" height="22" rx="10" ry="10"></rect>
<text x="968" y="44">param=value</text>
</g>
<path d="M1022 40h10"></path>
<path d="M914 40a10 10 0 0 0 -10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M914 70h40"></path>
<path d="M982 70h40"></path>
<rect x="954" y="59" width="28" height="22" rx="10" ry="10"></rect>
<text x="968" y="74">&#38;</text>
</g>
<path d="M1022 70a10 10 0 0 0 10 -10v-10a10 10 0 0 0 -10 -10"></path>
</g>
</g>
<path d="M1032 40h20"></path>
</g>
<path d="M 1052 40 h 20 m -10 -10 v 20 m 10 -20 v 20"></path>
</g>
</svg>

#### Patient-specific scopes

Patient-specific scopes allow access to specific data about a single patient.
*Which* patient is not specified here: FHIR Resource
scopes are all about *what* and not *who* which is handled in the next section.
Patient-specific scopes start with `patient/`.
Note that some EHRs may not enable access to all related resources (for
example, Practitioners linked to/from Patient-specific resources).
Note that if a FHIR server supports linking one Patient record with another
via `Patient.link`, the server documentation SHALL describe its authorization
behavior.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Read and search for all observations about a patient         | `patient/Observation.rs` |
Read demographics about a patient             | `patient/Patient.r`      | Note the difference in capitalization between "patient" the permission type and "Patient" the resource.
Add new blood pressure readings for a patient | `patient/Observation.c`  | Note that the permission is broader than the goal: with this scope, an app can add not only blood pressures, but other observations as well. Note also that write access does not imply read access.
Read all available data about a patient       | `patient/*.cruds`        | See notes on wildcard scopes below.
{:.grid}

#### User-level scopes

User-level scopes allow access to specific data that a user can access. Note
that this isn't just data *about* the user; it's data *available to* that user.
User-level scopes start with  `user/`.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Read a feed of all new lab observations across a patient population | `user/Observation.rs`    |
Manage all appointments to which the authorizing user has access    | `user/Appointment.cruds` | Individual attributes such as `d` for delete could be removed if not required.
Manage all resources on behalf of the authorizing user              | `user/*.cruds`           |
Select a patient                                                    | `user/Patient.rs`        | Allows the client app to select a patient.
{:.grid}

#### System-level scopes
System-level scopes describe data that a client system is directly authorized
to access; these scopes are useful in cases where there is no user in the loop,
such as a data monitoring or reporting service.  System-level scopes start with
`system/`.

Several examples are shown below:

Goal | Scope | Notes
-----|-------|-------
Alert engine to monitor all lab observations in a health system          | `system/Observation.rs` | Read-only access to observations.
Perform bulk data export across all available data within a FHIR server  | `system/*.rs`           | Full read/search for all resources.
System-level bridge, turning a V2 ADT feed into FHIR Encounter resources | `system/Encounter.cud`  | Write access to Encounters.
{:.grid}

#### Wildcard scopes

As noted previously, clients can request FHIR Resource scopes that contain a wildcard (`*`) for the FHIR resource. When a wildcard is requested for the FHIR resource, the client is asking for all data for all available FHIR resources, both now _and in the future_. This is an important distinction to understand, especially for the entity responsible for granting authorization requests from clients.

For instance, imagine a FHIR server that today just exposes the Patient resource. The authorization server asking a patient to authorize a SMART app requesting `patient/*.cruds` should inform the user that they are being asked to grant this SMART app access to not just the currently accessible data about them (patient demographics), but also any additional data the FHIR server may be enhanced to expose in the future (e.g., genetics).

As with any requested scope, the scopes ultimately granted by the authorization server may differ from the scopes requested by the client! This is often true when dealing with wildcard FHIR Resource scope requests.

As a best practice, clients should examine the granted scopes by the authorization server and respond accordingly. Failure to do so may lead to situations where the client receives an authorization failure by the FHIR server because it attempted to access FHIR resources beyond the granted scopes.

For example, consider a client with the goal of obtaining read and write access to a patient's allergies. If this client requests the FHIR Resource scope of `patient/AllergyIntolerance.cruds`, the authorization server may respond in a variety of ways with respect to the scopes that are ultimately granted. The following table outlines several, but not an exhaustive list of scenarios for this example:

Granted Scope | Notes
--------------|-------
`patient/AllergyIntolerance.cruds` | The client was granted exactly what it requested: patient-level read and write access to allergies via the same requested wildcard scope.
`patient/AllergyIntolerance.rs`<br />`patient/AllergyIntolerance.cud` | The client was granted exactly what it requested: patient-level CRUDS access to allergies. However, note that this was communicated via two explicit scopes rather than a single scope.
`patient/AllergyIntolerance.rs`    | The client was granted just patient-level read access to allergies.
`patient/AllergyIntolerance.cud`   | The client was granted just patient-level write access to allergies.
`patient/*.rs`                     | The client was granted read access to all data on the patient.
`patient/*.cruds`                  | The client was granted its requested scopes as well as read/write access to all other data on the patient.
`patient/Observation.rs`           | The client was granted an entirely different scope: patient-level read access to the patient's observations.  While this behavior is unlikely for a production quality authorization server, this scenario is technically possible.
`""` (empty scope string – no scopes granted) | The authorization server chose to not grant any of the requested scopes.
{:.grid}

As a best practice, clients are encouraged to request only the scopes and permissions they need to function and avoid the use of wildcard scopes purely for the sake of convenience. For instance, if your allergy management app requires patient-level read and write access to allergies, requesting the `patient/AllergyIntolerance.cruds` scope is acceptable. However, if your app only requires access to read allergies, requesting a scope of `patient/AllergyIntolerance.rs` would be more appropriate.

### Scopes for requesting context data

These scopes affect what context parameters will be provided in the access token response. Many apps rely on contextual data from the EHR to answer questions like:

* Which patient record is currently "open" in the EHR?
* Which encounter is currently "open" in the EHR?
* At which clinic, hospital ward, or patient room is the end-user currently working?

To request access to such details, an app asks for "launch context" scopes in
addition to whatever FHIR Resource access scopes it needs. Launch context scopes are
easy to tell apart from FHIR Resource scopes, because they always begin with
`launch`.

Requested Scope | Meaning
----------------|---------
`launch/patient`   | Need patient context at launch time (FHIR Patient resource).
`launch/encounter` | Need encounter context at launch time (FHIR Encounter resource).
<span class="expSpan">Others </span>{%include exp.html%}          | <span class="expSpan">Any SMART EHR MAY extend this list to support additional context.  When specifying resource types, convert the type names to *all lowercase* (e.g., `launch/diagnosticreport`). In situations where the same resource type might be used for more than one purpose (e.g., in a medication reconciliation app, one List of at-home medications and another List of in-hospital medications), the app can solicit context with a specific role by appending `?role={role}` (see [example below](#fhircontext-example-medication-reconciliation)).</span>
{:.grid}

When using `?role=` in launch context requests:
* Each requested scope can include at most one role. If an app requires multiple roles, it MAY request multiple scopes (e.g., `launch/relatedperson?role=friend` and `launch/relatedperson?role=neighbor`).
* If an EHR receives a request for an unsupported role, it SHOULD return any launch context supported for the supplied resource type. It MAY return alternative roles.



There are two general approaches to asking for launch context data depending
on the details of how your app is launched.

#### Apps that launch from the EHR

Apps that launch from the EHR will be passed an explicit URL parameter called
`launch`, whose value must associate the app's
authorization request with the current EHR session.  For example, If an app receives the URL
parameter `launch=abc123`, then it requests the scope `launch` and provides an
additional URL parameter of `launch=abc123`.

The application could choose to also provide `launch/patient`,
`launch/encounter`, or other `launch/` scopes as “hints” regarding which
contexts the app would like the EHR to gather. The EHR MAY ignore these hints
(for example, if the user is in a workflow where these contexts do not exist).

If an application requests a FHIR Resource scope which is restricted to a single patient (e.g., `patient/*.rs`), and the authorization results in the EHR granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch`, or it MAY infer the `launch/patient` scope.

#### Standalone apps

Standalone apps that launch outside the EHR do not have any EHR context at the outset. These apps must explicitly request EHR context. The EHR SHOULD provide the requested context if requested by the following scopes, unless otherwise noted.

Note on `launch/patient`: If an application requests a scope which is restricted to a single patient (e.g., `patient/*.rs`), and the authorization results in the EHR granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch/patient` scope, or it MAY infer the `launch/patient` scope.


#### Launch context arrives with your `access_token`

Once an app is authorized, the token response will include any context data the
app requested and any (potentially) unsolicited context data the EHR may
decide to communicate. For example, EHRs may use launch context to communicate
UX and UI expectations to the app (see `need_patient_banner` below).

Launch context parameters come alongside the access token. They will appear as JSON
parameters:

```js
{
  "access_token": "secret-xyz",
  "patient": "123",
  "fhirContext": [{"reference": "DiagnosticReport/123"}, {"reference": "Organization/789"}],
//...
}
```

Some common launch context parameters are shown in the example below. The following sections provides further details:

Launch context parameter | Example value | Meaning
-------------------------|---------------|---------
`patient`             | `"123"`                                  | String value with a patient id, indicating that the app was launched in the context of FHIR Patient 123. If the app has any patient-level scopes, they will be scoped to Patient 123.
`encounter`           | `"123"`                                  | String value with an encounter id, indicating that the app was launched in the context of FHIR Encounter 123.
`fhirContext`         | `[{"reference": "Appointment/123"}]`                    | Array of objects referring to any resource type other than "Patient" or "Encounter". See [details below](#fhir-context).
`need_patient_banner` | `true` or `false` (boolean)              | Boolean value indicating whether the app was launched in a UX context where a patient banner is required (when `true`) or may not be required (when `false`). An app receiving a value of false might not need to take up screen real estate displaying a patient banner.
`intent`              | `"reconcile-medications"`                | String value describing the intent of the application launch (see notes [below](#launch-intent))
`smart_style_url`     | `"https://ehr/styles/smart_v1.json"`     | String URL where the EHR's style parameters can be retrieved (for apps that support [styling](#styling))
`tenant`              | `"2ddd6c3a-8e9a-44c6-a305-52111ad302a2"` | String conveying an opaque identifier for the healthcare organization that is launching the app. This parameter is intended primarily to support EHR Launch scenarios.
{:.grid}

<a id="fhir-context"></a>
#### `fhirContext` {%include exp.html%}

{%include exp-div.html%} To allow application flexibility, maintain backwards compatibility, and keep a
predictable JSON structure, any contextual resource types that were requested
by a launch scope will appear in the `fhirContext` array. The two exceptions are
Patient and Encounter resource types, which will *not be deprecated from top-level
parameters*, and they will *not be permitted* within the `fhirContext` array unless they
include a `role` other than `"launch"`. 

Each object in the `fhirContext` array SHALL include at least one of
`"reference"`, `"canonical"`, or `"identifier"`, and MAY contain additional
properties:


* `"reference"` (string): relative reference to a FHIR resource. Note that there MAY be more than one `fhirContext` item referencing the same type of resource.

* `"canonical"` (string):  canonical URL for the `fhirContext` item (MAY include a version suffix)

* `"identifier"` (object):  FHIR Identifier for the `fhirContext` item

* `"type"` (string): FHIR resource type of the `fhirContext` item (RECOMMENDED when `"identifier"` or `"canonical"` is present)

* `"role"` (string):  URI identifying the role of this `fhirContext` item.
Relative role URIs can only be used if they are defined in this specification; other
roles require the use of absolute URIs. This property MAY be omitted and SHALL
NOT be the empty string. The absence of a role property is semantically
equivalent to a role of `"launch"`, indicating to a client that the app launch
was performed in the context of the referenced resource. More granular role URIs
can be adopted in use-case-specific ways. Multiple `fhirContext` items MAY have
the same role.
  * Note: Specifications defining custom roles can list them in the
[fhirContext Role Registry](https://confluence.hl7.org/display/FHIRI/fhirContext+Role+Registry) to
promote awareness and reuse.
  * Note: We have not yet defined a protocol for apps to discover which roles an EHR supports; as such, it is important for EHRs to include this information in their developer documentation.


Note that for `"identifier"` and `"canonical"`, this specification does not
define rules for access control. The app may reach out to different servers to
resolve these, authenticating as needed.


<a id="fhircontext-examples"></a>

##### `fhirContext` example: EHR Launch with Imaging Study

If a SMART on FHIR server supports additional launch context during an EHR
Launch, it could communicate the ID of an `ImagingStudy` that is open in the
EHR at the time of app launch.  The server could return an access token response
where the `fhirContext` array includes a value such as `{"reference": "ImagingStudy/123"}`.

##### `fhirContext` example: Standalone Launch with Imaging Study

If a SMART on FHIR server supports additional launch context during a
Standalone Launch, it could provide an ability for the user to select an
`ImagingStudy` during the launch.  A client could request this behavior by
requesting a `launch/imagingstudy` scope (note that launch requests scopes are
always lower case); then after allowing the user to select an `ImagingStudy`,
the server could return an access token response where the `fhirContext` array
includes a value such as  `{"reference": "ImagingStudy/123"}`.

##### `fhirContext` example: Medication Reconciliation

If a medication reconciliation app expects distinct contextual inputs
representing an at-home medication list and an in-hospital medication list, the
app might request context using scopes like:

* `launch/list?role=https://example.org/med-list-at-home`
* `launch/list?role=https://example.org/med-list-at-hospital`

Based on this request or pre-configured settings, the EHR might supply
`fhirContext` like:

```json
{
  // other properties omitted for brevity
  "patient": "123",
  "fhirContext": [{
    "reference": "List/123",
    "role": "https://example.org/med-list-at-home"
  }, {
    "reference": "List/456",
    "role": "https://example.org/med-list-at-hospital"
  }]
}
```

##### `fhirContext` example: Canonical Questionnaire

If a data-gathering app expects to receive a canonical URL for a FHIR Questionnaire, 
the EHR might supply `fhirContext` like:

```json
{
  // other properties omitted for brevity
  "patient": "123",
  "fhirContext": [{
    "role": "https://example.org/role/questionnaire-to-display",
    "type": "Questionnaire",
    "canonical": "https://example.org/Questionnaire/123/|v2023-05-03"
  }]
}
```
</div>

<h5 id="launch-intent"><b>App Launch Intent</b> (optional)</h5>
`intent`: Some SMART apps might offer more than one context or user interface
that can be accessed during the SMART launch. The optional `intent` parameter
in the launch context provides a mechanism for the SMART EHR to communicate to
the client app which specific context should be displayed as the outcome of the
launch. This allows for closer integration between the EHR and client, so that
different launch points in the EHR UI can target specific displays within the
client app.

For example, a patient timeline app might provide three specific UI contexts,
and inform the SMART EHR (out of band, at app configuration time)  of the
`intent` values that can be used to launch the app directly into one of the
three contexts. The app might respond to `intent` values like:

* `summary-timeline-view` - a default UI context, showing a data summary
* `recent-history-timeline` - a history display, showing a list of entries
* `encounter-focused-timeline` - a timeline focused on the currently in-context encounter

If a SMART EHR provides a value that the client does not recognize, or does
not provide a value, the client app SHOULD display a default application UI
context.

Note that *SMART makes no effort to standardize `intent` values*.  Intents simply
provide a mechanism for tighter custom integration between an app and a SMART
EHR. The meaning of intent values must be negotiated between the app and the EHR.

##### SMART App Styling (experimental[^1]) {%include exp.html%}
{: #styling}
{%include exp-div.html%}
`smart_style_url`: In order to mimic the style of the SMART EHR more closely,
SMART apps can check for the existence of this launch context parameter and,  if provided,
download the JSON file referenced by the URL value.

The URL SHOULD serve a "SMART Style" JSON object with one or more of the following properties:

``` text
{
  color_background: "#edeae3",
  color_error: "#9e2d2d",
  color_highlight: "#69b5ce",
  color_modal_backdrop: "",
  color_success: "#498e49",
  color_text: "#303030",
  dim_border_radius: "6px",
  dim_font_size: "13px",
  dim_spacing_size: "20px",
  font_family_body: "Georgia, Times, 'Times New Roman', serif",
  font_family_heading: "'HelveticaNeue-Light', Helvetica, Arial, 'Lucida Grande', sans-serif;"
}
```

The URL value itself is to be considered a version key for the contents of the SMART Style JSON:
EHRs SHALL return a new URL value in the `smart_style_url` launch context parameter if the contents
of this JSON is changed.

Style Property | Description
---------------|-------------
`color_background`     | The color used as the background of the app.
`color_error`          | The color used when UI elements need to indicate an area or item of concern or dangerous action, such as a button to be used to delete an item, or a display an error message.
`color_highlight`      | The color used when UI elements need to indicate an area or item of focus, such as a button used to submit a form, or a loading indicator.
`color_modal_backdrop` | The color used when displaying a backdrop behind a modal dialog or window.
`color_success`        | The color used when UI elements need to indicate a positive outcome, such as a notice that an action was completed successfully.
`color_text`           | The color used for body text in the app.
`dim_border_radius`    | The base corner radius used for UI element borders (0px results in square corners).
`dim_font_size`        | The base size of body text displayed in the app.
`dim_spacing_size`     | The base dimension used to space UI elements.
`font_family_body`     | The list of typefaces to use for body text and elements.
`font_family_heading`  | The list of typefaces to use for content heading text and elements.
{:.grid}

SMART client apps that can adjust their styles should incorporate the above
property values into their stylesheets, but are not required to do so.

Optionally, if the client app detects a new version of the SMART Style object
(i.e. a new URL is returned the `smart_style_url` parameter), the client can
store the new property values and request approval to use the new values from
a client app stakeholder. This allows for safeguarding against poor usability
that might occur from the immediate use of these values in the client app UI.
</div>

### Scopes for requesting identity data

Some apps need to authenticate the end-user.  This can be accomplished by
requesting the scope `openid`.  When the `openid` scope is requested, apps can
also request the `fhirUser` scope to obtain a FHIR resource representation of
the current user.  Single sign-on support with `fhirUser` requires that users
can be represented as FHIR resources. If the EHR cannot represent the user with
a FHIR resource, it cannot support the `fhirUser` scope.

When these scopes are requested (and the request is granted), the app will
receive an [`id_token`](http://openid.net/specs/openid-connect-core-1_0.html#CodeIDToken)
that comes alongside the access token.

This token must be [validated according to the OIDC specification](http://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation).
To learn more about the user, the app should treat the `fhirUser` claim as the
URL of a FHIR resource representing the current user.  This URL MAY be absolute
(e.g., `https://ehr.example.org/Practitioner/123`), or it MAY be relative to
the FHIR server base URL associated with the current authorization request
(e.g., `Practitioner/123`).  This will be a resource of type `Patient`,
`Practitioner`, `PractitionerRole`, `RelatedPerson`, or `Person`.
Note that the FHIR server base URL is the same as the URL represented in the
`aud` parameter passed in to the authorization request.
Note that `Person` is only used if the other resource types do not apply to the
current user, for example, the "authorized representative" for >1 patients.

The [OpenID Connect Core specification](http://openid.net/specs/openid-connect-core-1_0.html)
describes a wide surface area with many optional capabilities. To be considered compatible
with the SMART's `sso-openid-connect` capability, the following requirements apply:

 * Response types: The EHR SHALL support the Authorization Code Flow, with the request parameters as defined in [SMART App Launch](app-launch.html). Support is not required for parameters that OIDC lists as optional (e.g., `id_token_hint`, `acr_value`), but EHRs are encouraged to review these optional parameters.

 * Public Keys Published as Bare JWK Keys: The EHR SHALL publish public keys as bare JWK keys (which MAY also be accompanied by X.509 representations of those keys).

 * Claims: The EHR SHALL support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the `openid` and `fhirUser` scopes.

* Signed ID Token: The EHR SHALL support Signing ID Tokens with RSA SHA-256.

* A SMART app SHALL NOT pass the `auth_time` claim or `max_age` parameter to a server that does not support receiving them.

Servers MAY include support for the following features:

 * `claims` parameters on the authorization request
 * Request Objects on the authorization request
 * UserInfo endpoint with claims exposed to clients

### Scopes for requesting a refresh token

To request a `refresh_token` that can be used to obtain a new access token
after the current access token expires, add one of the following scopes:

Scope | Grants
------|--------
`online_access`    | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.
`offline_access`   | Request a `refresh_token` that can be used to obtain a new access token to replace an expired token, and that will remain usable for as long as the authorization server and end-user will allow, regardless of whether the end-user is online.
{:.grid}

### Extensibility

In addition to conveying FHIR Resource references with the `fhirContext` array, additional context parameters and scopes can be used as extensions using the following namespace conventions:

- use a *full URI* that you control (e.g., http://example.com/scope-name)
- use any string starting with `__` (two underscores)

#### Example: Extra context - `fhirContext` for FHIR Resource References

See Section [`fhirContext` Examples](#fhircontext-examples).

#### Example: Extra context - extensions for non-FHIR context

If a SMART on FHIR server wishes to communicate additional context (such
as a custom "dark mode" flag to provide clients a hint about whether they
should render a UI suitable for use in low-light environments), it could
accomplish this by returning an access token response where an extension
property is present.  The server could choose an extension property as a full URL
(e.g., `{..., "https://ehr.example.org/props/dark-mode": true}`) or by using a
`"__"` prefix (e.g., `{..., "__darkMode": true}`).

#### Example: Extra scopes - extensions for non-FHIR APIs

If a SMART on FHIR server supports a custom behavior like allowing users
to choose their own profile photos through a custom non-FHIR API, it
can designate a custom scope using a full URL (e.g.,
`https://ehr.example.org/scopes/profilePhoto.manage`) or by using a `"__"`
prefix (e.g., `__profilePhoto.manage`).  The server could advertise this scope in its developer-facing
documentation, and also in the `scopes_supported` array of its
`.well-known/smart-configuration` file.  Clients requesting authorization could
include this scope alongside other standardized scopes, so the `scope`
parameter of the authorization request might look like:
`launch/patient patient/*.rs __profilePhoto.manage`.  If the user grants these
scopes, the access token response would then include a `scope` value that
matches the original request.

### Steps for using an ID token

 1. Examine the ID token for its "issuer" property
 2. Perform a `GET {issuer}/.well-known/openid-configuration`
 3. Fetch the server's JSON Web Key by following the "jwks_uri" property
 4. Validate the token's signature against the public key from step #3
 5. Extract the `fhirUser` claim and treat it as the URL of a FHIR resource

### Worked examples

- Worked Python example: [rendered](worked_example_id_token.html)

### Appendix: URI representation of scopes

In some circumstances, scopes must be represented as URIs. For example, when exchanging what scopes users are allowed to have, or sharing what scopes a user has chosen. When URI representations are required, the SMART scopes SHALL be prefixed with `http://smarthealthit.org/fhir/scopes/`, so that a `patient/*.r` scope would be `http://smarthealthit.org/fhir/scopes/patient/*.r`.

To represent OpenID scopes as URIs, the prefix `http://openid.net/specs/openid-connect-core-1_0#` SHALL be used.

---

<br />

[^1]: Section is marked as "experimental" to indicate that there may be future backwards-incompatible changes to the style document pointed to by the `smart_style_url`.
