<!-- # SMART App Launch: Scopes and Launch Context-->

SMART on FHIR's authorization scheme uses OAuth scopes to communicate (and
negotiate) access requirements. Providing apps with access to broad data sets is consistent with current common practices (e.g. interface engines also provide access to broad data sets); access is also limited based on the privileges of the user in context.  In general, we use scopes for three kinds of data:

1. [Clinical data](#scopes-for-requesting-clinical-data)
1. [Contextual data](#scopes-for-requesting-context-data)
1. [Identity data](#scopes-for-requesting-identity-data)

Launch context is a negotiation where a client asks for specific launch context
parameters (e.g. `launch/patient`). A server can decide which launch context
parameters to provide, using the client's request as an input into the decision
process.  When granting a patient-level scopes like `patient/*.rs`, the server
SHALL provide a "patient" launch context parameter.

### Quick Start

Here is a quick overview of the most commonly used scopes. Read on below for complete details.

|Scope | Grants|
|---|---
|`patient/*.rs`|Permission to read and search any resource for the current patient (see notes on wildcard scopes below)|
|`user/*.cruds`| Permission to read and write all resources that the current user can access (see notes on wildcard scopes below)|
| `openid` `fhirUser` (or `openid` `profile`)| Permission to retrieve information about the current logged-in user|
|`launch`| Permission to obtain launch context when app is launched from an EHR|
|`launch/patient`| When launching outside the EHR, ask for a patient to be selected at launch time|
|`offline_access`| Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, even after the end-user no longer is online after the access token expires|
|`online_access`| Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.|

### Scopes for requesting clinical data

SMART on FHIR defines OAuth2 access scopes that correspond directly to FHIR resource types. These scopes impact the access an application may have to FHIR resources (and actions). We define permissions to support the following FHIR REST API interactions:

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


Valid suffixes are a subset of the in-order string `.cruds`. For example, to convey support for creating and updating observations, use scope `patient/Observation.cu`. To convey support for reading and searching observations, use scope `patient/Observation.rs`. For backwards compatibility with scopes defined in the SMART App Launch 1.0 specification, servers SHOULD advertise the `permission-v1` capability in their `.well-known/smart-configuration` discovery document, SHOULD return v1 scopes when v1 scopes are requested and granted, and SHOULD process v1 scopes with the following semantics in v2:

* v1 `.read` ⇒ v2 `.rs`
* v1 `.write` ⇒ v2 `.cud`
* v1 `.*` ⇒ v2 `.cruds`

Scope requests with undefined or out of order interactions MAY be ignored, replaced with server default scopes, or rejected. For example, a request of `.dus` is not a defined scope request. This policy is to prevent misinterpretation of scopes with other conventions (e.g., interpreting `.read` as `.rd` and granting extraneous delete permissions).

#### Batches and Transactions

SMART 2.0 does not define specific scopes for [batch or transaction](http://hl7.org/fhir/http.html#transaction) interactions. These system-level interactions are simply convience wrappers for other interactions. As such, batch and transaction requests should be validated based on the actual requests within them.

#### Scope Equivalence

Multiple scopes compounded or expanded are equivalent to each other.  E.g., `Observation.rs` is interchangeable with `Observation.r Observation.s`. In order to reduce token size, it is recomended that scopes be factored to their shortest form.

#### Finer-grained resource constraints using search parameters

In SMART 1.0, scopes were based entirely on FHIR Resource types, as in `patient/Observation.read` (for Observations) or `patient.Immunization.read` (for Immunizations). In SMART 2.0, we provide more detailed constraints based on FHIR REST API search parameter syntax. To apply these constraints, add a query string suffix to existing scopes, starting with `?` and followed by a series of `param=value` items separated by `&`. For example, to request read and search access to laboratory observations but not other observations, the scope `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|laboratory`.

#### Requirements for support

While the search parameter based syntax here is quite general, and could be used for any search parameter defined in FHIR, we're seeking community consensus on a small common core of search parameters for broad support. Initially, servers supporting SMART v2 scopes SHALL support:

* `category=` constraints for any supported resource types where `category` is a defined search parameter. This includes support for category-based Observation access on any server that supports Observation access.

#### Experimental features

Because the search parameter based syntax here is quite general, it opens up the possibility of using many features that servers may have trouble supporting in a consistent and performant fashion. Given the current level of implementation experience, the following features should be considered experimental, even if they are supported by a server:

* Use of search modifiers such as `Observation.rs?code:in=http://valueset.example.org/ValueSet/diabetes-codes`
* Use of search parameter chaining such as `Observation.rs?patient.birthdate=1990`
* Use of FHIR's `_filter` capabilities


#### Scope size over the wire

Scope strings appear over the wire at several points in an OAuth flow. Implementers should be aware that fine-grained controls can lead to a proliferation of scopes, increasing in the length of the `scope` string for app authorizations. As such, implementers should take care to avoid putting arbitrarily large scope strings in places where they might not "fit". The following considerations apply, presented in the sequential order of a SMART App Launch:

* When initiating an authorization request, app developers should prefer POST-based authorization requests to GET-based requests, since this avoid URL length limits that might apply to GET-based authorization requests. (For example, somme current-generation browsers have a 32kB length limit for values displayed in the URL bar.)
* In the authorization code redirect response, no scopes are included, so these considerations do not apply.
* In the access token response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the token introspection response, no specific limits apply, since this payload comes in response to a client-initiated POST.
* In the access token itself, implementation-specific considerations may apply. SMART leaves access token formats out of scope, so formally there are no restrictions. But since access tokens are included in HTTP headers, servers should take care to ensure they do not get too large. For example, some current-generation HTTP servers have an 8kB limit on header length. To remain under this limit, authorization servers that use structured token formats like JWT might consider embedding handles or pointers to scopes, rather than embedding literal scopes in an access token. Alternatively, authorization servers might establish an internal convention mapping shorter scope names into longer scopes (or common combinations of longer scopes).


#### Clinical Scope Syntax

Expressed as a railroad diagram, the scope language is:


<svg class="railroad-diagram" width="1094" height="131" viewBox="0 0 1094 131" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
<!--
https://github.com/tabatkins/railroad-diagrams
Diagram(
  Choice(0, 'patient', 'user', 'system'),
  Choice(0, '/'),
  Choice(0, 'FHIR Resource Type', '*'),
  Choice(0, '.'),
  OptionalSequence('c', 'r', 'u', 'd', 's'),
  Optional(
    Sequence('?', OneOrMore('param=value&')))
)
-->

<g transform="translate(.5 .5)">
<g>
<path d="M20 30v20m10 -20v20m-10 -10h20"></path>
</g>
<g>
<path d="M40 40h0"></path>
<path d="M159.5 40h0"></path>
<path d="M40 40h20"></path>
<g class="terminal ">
<path d="M60 40h0"></path>
<path d="M139.5 40h0"></path>
<rect x="60" y="29" width="79.5" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="44">patient</text>
</g>
<path d="M139.5 40h20"></path>
<path d="M40 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 70h12.75"></path>
<path d="M126.75 70h12.75"></path>
<rect x="72.75" y="59" width="54" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="74">user</text>
</g>
<path d="M139.5 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
<path d="M40 40a10 10 0 0 1 10 10v40a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M60 100h4.25"></path>
<path d="M135.25 100h4.25"></path>
<rect x="64.25" y="89" width="71" height="22" rx="10" ry="10"></rect>
<text x="99.75" y="104">system</text>
</g>
<path d="M139.5 100a10 10 0 0 0 10 -10v-40a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M159.5 40h0"></path>
<path d="M228 40h0"></path>
<path d="M159.5 40h20"></path>
<g class="terminal ">
<path d="M179.5 40h0"></path>
<path d="M208 40h0"></path>
<rect x="179.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="193.75" y="44">/</text>
</g>
<path d="M208 40h20"></path>
</g>
<g>
<path d="M228 40h0"></path>
<path d="M441 40h0"></path>
<path d="M228 40h20"></path>
<g class="terminal ">
<path d="M248 40h0"></path>
<path d="M421 40h0"></path>
<rect x="248" y="29" width="173" height="22" rx="10" ry="10"></rect>
<text x="334.5" y="44">FHIR Resource Type</text>
</g>
<path d="M421 40h20"></path>
<path d="M228 40a10 10 0 0 1 10 10v10a10 10 0 0 0 10 10"></path>
<g class="terminal ">
<path d="M248 70h72.25"></path>
<path d="M348.75 70h72.25"></path>
<rect x="320.25" y="59" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="334.5" y="74">&#42;</text>
</g>
<path d="M421 70a10 10 0 0 0 10 -10v-10a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M441 40h0"></path>
<path d="M509.5 40h0"></path>
<path d="M441 40h20"></path>
<g class="terminal ">
<path d="M461 40h0"></path>
<path d="M489.5 40h0"></path>
<rect x="461" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="475.25" y="44">.</text>
</g>
<path d="M489.5 40h20"></path>
</g>
<g>
<path d="M509.5 40h0"></path>
<path d="M832 40h0"></path>
<path d="M509.5 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10h28.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M509.5 40h20"></path>
<g class="terminal ">
<path d="M529.5 40h0"></path>
<path d="M558 40h0"></path>
<rect x="529.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="543.75" y="44">c</text>
</g>
<path d="M558 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M558 40h20"></path>
<g class="terminal ">
<path d="M578 40h0"></path>
<path d="M606.5 40h0"></path>
<rect x="578" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="592.25" y="44">r</text>
</g>
<path d="M606.5 40h20"></path>
<path d="M558 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M626.5 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M626.5 40h20"></path>
<g class="terminal ">
<path d="M646.5 40h0"></path>
<path d="M675 40h0"></path>
<rect x="646.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="660.75" y="44">u</text>
</g>
<path d="M675 40h20"></path>
<path d="M626.5 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M695 20h68.5a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M695 40h20"></path>
<g class="terminal ">
<path d="M715 40h0"></path>
<path d="M743.5 40h0"></path>
<rect x="715" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="729.25" y="44">d</text>
</g>
<path d="M743.5 40h20"></path>
<path d="M695 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<path d="M763.5 40h20"></path>
<g class="terminal ">
<path d="M783.5 40h0"></path>
<path d="M812 40h0"></path>
<rect x="783.5" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="797.75" y="44">s</text>
</g>
<path d="M812 40h20"></path>
<path d="M763.5 40a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10h28.5a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
</g>
<g>
<path d="M832 40h0"></path>
<path d="M1054 40h0"></path>
<path d="M832 40a10 10 0 0 0 10 -10v0a10 10 0 0 1 10 -10"></path>
<g>
<path d="M852 20h182"></path>
</g>
<path d="M1034 20a10 10 0 0 1 10 10v0a10 10 0 0 0 10 10"></path>
<path d="M832 40h20"></path>
<g>
<path d="M852 40h0"></path>
<path d="M1034 40h0"></path>
<g class="terminal ">
<path d="M852 40h0"></path>
<path d="M880.5 40h0"></path>
<rect x="852" y="29" width="28.5" height="22" rx="10" ry="10"></rect>
<text x="866.25" y="44">?</text>
</g>
<path d="M880.5 40h10"></path>
<path d="M890.5 40h10"></path>
<g>
<path d="M900.5 40h0"></path>
<path d="M1034 40h0"></path>
<path d="M900.5 40h10"></path>
<g class="terminal ">
<path d="M910.5 40h0"></path>
<path d="M1024 40h0"></path>
<rect x="910.5" y="29" width="113.5" height="22" rx="10" ry="10"></rect>
<text x="967.25" y="44">param=value&</text>
</g>
<path d="M1024 40h10"></path>
<path d="M910.5 40a10 10 0 0 0 -10 10v0a10 10 0 0 0 10 10"></path>
<g>
<path d="M910.5 60h113.5"></path>
</g>
<path d="M1024 60a10 10 0 0 0 10 -10v0a10 10 0 0 0 -10 -10"></path>
</g>
</g>
<path d="M1034 40h20"></path>
</g>
<path d="M 1054 40 h 20 m -10 -10 v 20 m 10 -20 v 20"></path>
</g>
<style>
	svg {
		background-color: hsl(30,20%,95%);
	}
	path {
		stroke-width: 3;
		stroke: black;
		fill: rgba(0,0,0,0);
	}
	text {
		font: bold 14px monospace;
		text-anchor: middle;
		white-space: pre;
	}
	text.diagram-text {
		font-size: 12px;
	}
	text.diagram-arrow {
		font-size: 16px;
	}
	text.label {
		text-anchor: start;
	}
	text.comment {
		font: italic 12px monospace;
	}
	g.non-terminal text {
		/&#42;font-style: italic;&#42;/
	}
	rect {
		stroke-width: 3;
		stroke: black;
		fill: hsl(120,100%,90%);
	}
	rect.group-box {
		stroke: gray;
		stroke-dasharray: 10 5;
		fill: none;
	}
	path.diagram-text {
		stroke-width: 3;
		stroke: black;
		fill: white;
		cursor: help;
	}
	g.diagram-text:hover path.diagram-text {
		fill: #eee;
	}</style>
</svg>

#### Patient-specific scopes

Patient-specific scopes allow access to specific data about a single patient.
*Which* patient is not specified here: clinical data
scopes are all about *what* and not *who* which is handled in the next section.
Patient-specific scopes start with `patient/`.  Note that some EHRs may not enable access to all related resources - for example, Practitioners linked to/from Patient-specific resources.

Let's look at a few examples:

Goal | Scope | Notes
-----|-------|-----
Read all observations about a patient | `patient/Observation.rs` |
Read demographics about a patient | `patient/Patient.rs` | Note the difference in capitalization between "patient" the permission type and "Patient" the resource.
Add new blood pressure readings for a patient| `patient/Observation.c`| Note that the permission is broader than our goal: with this scope, an app can add not only blood pressures, but other observations as well. Note also that write access does not imply read access.
Read all available data about a patient| `patient/*.cruds`| See notes on wildcard scopes below |

#### User-level scopes

User-level scopes allow access to specific data that a user can access. Note
that this isn't just data *about* the user; it's data *available to* that user.
User-level scopes start with  `user/`.

Let's look at a few examples:

Goal | Scope | Notes
-----|-------|-----
Read a feed of all new lab observations across a patient population | `user/Observation.rs` |
Manage all appointments to which the authorizing user has access | `user/Appointment.cruds` | Individual attributes such as `d` for delete could be removed if not required.
Manage all resources on behalf of the authorizing user | `user/*.cruds`|
Select a patient| `user/Patient.rs` | Allows the client app to select a patient.

#### System-level scopes
System-level scopes describe data that a client system is directly authorized
to access; these scopes are useful in cases where there is no user in the loop,
such as a data monitoring or reporting service.  System-level scopes start with
`system/`.

Let’s look at a few examples:

Goal | Scope | Notes
-----|-------|------
Alert engine to monitor all lab observations in a health system | `system/Observation.rs` | Read-only access to observations.
Perform bulk data export across all available data within a FHIR server | `system/*.rs` | Full read/search for all resources.
System-level bridge, turning a V2 ADT feed into FHIR Encounter resources | `system/Encounter.cud` | Write access to Encounters.

#### Wildcard scopes

As noted previously, clients can request clinical scopes that contain a wildcard (`*`) for the FHIR resource. When a wildcard is requested for the FHIR resource, the client is asking for all data for all available FHIR resources, both now _and in the future_. This is an important distinction to understand, especially for the entity responsible for granting authorization requests from clients.

For instance, imagine a FHIR server that today just exposes the Patient resource. The authorization server asking a patient to authorize a SMART app requesting `patient/*.cruds` should inform the user that they are being asked to grant this SMART app access to not just the currently accessible data about them (patient demographics), but also any additional data the FHIR server may be enhanced to expose in the future (eg, genetics).

As with any requested scope, the scopes ultimately granted by the authorization server may differ from the scopes requested by the client! When dealing with wildcard clinical scope requests, this is often true.

As a best practice, clients should examine the granted scopes by the authorization server and respond accordingly. Failure to do so may lead to situations in which the client attempts to access FHIR resources they were not granted access only to receieve an authorization failure by the FHIR server.

For example, imagine a client with the goal of obtaining read and write access to a patient's allergies and as such, requests the clinical scope of `patient/AllergyIntolerance.cruds`. The authorization server may respond in a variety of ways with respect to the scopes that are ultimately granted. The following table outlines several, but not an exhaustive list of scenarios for this example:

Granted Scope | Notes
--------------|---------------
`patient/AllergyIntolerance.cruds` | The client was granted exactly what it requested: patient-level read and write access to allergies via the same requested wildcard scope.
`patient/AllergyIntolerance.rs`<br />`patient/AllergyIntolerance.cud` | The client was granted exactly what it requested: patient-level CRUDS access to allergies. However, note that this was communicated via two explicit scopes rather than a single  scope.
`patient/AllergyIntolerance.rs` | The client was granted just patient-level read access to allergies.
`patient/AllergyIntolerance.cud` | The client was granted just patient-level write access to allergies.
`patient/*.rs` | The client was granted read access to all data on the patient.
`patient/*.cruds` | The client was granted its requested scopes as well as read/write access to all other data on the patient.
`patient/Observation.rs` | The client was granted an entirely different scope: patient-level read access to the patient's observations. While this behavior is unlikely for a production quality authorization server, this scenario is technically possible.
_none_ | The authorization server chose to not grant any of the requested scopes.

As a best practice, clients are encouraged to request only the scopes and permissions they need to function and avoid the use of wildcard scopes purely for the sake of convenience. For instance, if your allergy management app requires patient-level read and write access to allergies, requesting the `patient/AllergyIntolerance.cruds` scope is acceptable. However, if your app only requires access to read allergies, requesting a scope of `patient/AllergyIntolerance.rs` would be more appropriate.

### Scopes for requesting context data

These scopes affect what context parameters will be provided in the access token response. Many apps rely on contextual data from the EHR to answer questions like:

* Which patient record is currently "open" in the EHR?
* Which encounter is currently "open" in the EHR?
* At which clinic, hospital ward, or patient room is the end-user currently working?

To request access to such details, an app asks for "launch context" scopes in
addition to whatever clinical access scopes it needs. Launch context scopes are
easy to tell apart from clinical data scopes, because they always begin with
`launch`.

There are two general approaches to asking for launch context data, depending
on the details of how your app is launched.

#### Apps that launch from the EHR

Apps that launch from the EHR will be passed an explicit URL parameter called
`launch`, whose value must associate the app's
authorization request with the current EHR session.  For example, If an app receives the URL
parameter `launch=abc123`, then it requests the scope `launch` and provides an
additional URL parameter of `launch=abc123`.

The application could choose to also provide `launch/patient` and/or `launch/encounter` as "hints" regarding which contexts the app would like the EHR to gather. The EHR MAY ignore these hints (for example, if the user is in a workflow where these contexts do not exist).

If an application requests a clinical scope which is restricted to a single patient (e.g. `patient/*.rs`), and the authorization results in the EHR is granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch`, or it MAY infer the `launch/patient` scope.

#### Standalone apps

Standalone apps that launch outside the EHR do not have any EHR context at the outset. These apps must explicitly request EHR context. The EHR SHOULD provide the requested context if requested by the following scopes, unless otherwise noted:

##### Requesting context with scopes

Requested Scope | Meaning
---------|-------------------
`launch/patient` | Need patient context at launch time (FHIR Patient resource). See note below.
`launch/encounter` | Need encounter context at launch time (FHIR Encounter resource).
(Others)| This list can be extended by any SMART EHR if additional context is required.

Note on `launch/patient`: If an application requests a clinical scope which is restricted to a single patient (e.g. `patient/*.rs`), and the authorization results in the EHR granting that scope, the EHR SHALL establish a patient in context. The EHR MAY refuse authorization requests including `patient/` that do not also include a valid `launch/patient` scope, or it MAY infer the `launch/patient` scope.

#### Launch context arrives with your `access_token`

Once an app is authorized, the token response will include any context data the
app requested -- along with (potentially!) any unsolicited context data the EHR
decides to communicate. For example, EHRs may use launch context to communicate
UX and UI expectations to the app (see `need_patient_banner` below).

Launch context parameters come alongside the access token. They will appear as JSON
parameters:

```  text
{
  access_token: "secret-xyz",
  patient: "123",
  ...
}
```
Here are the launch context parameters to expect:

Launch context parameter | Example value | Meaning
------|---------|-------------------
`patient` | `"123"`| String value with a patient id, indicating that the app was launched in the context of FHIR Patient 123. If the app has any patient-level scopes, they will be scoped to Patient 123.
`encounter` | `"123"`| String value with an encounter id, indicating that the app was launched in the context of FHIR Encounter 123.
`appointment` | `"789"` | String value with an appointment id, indicating that the app was launched in the context of FHIR Appointment 789.
`need_patient_banner` | `true` or `false` (boolean) | Boolean value indicating whether the app was launched in a UX context where a patient banner is required (when `true`) or not required (when `false`). An app receiving a value of `false` should not take up screen real estate displaying a patient banner.
`intent` | `"reconcile-medications"`| String value describing the intent of the application launch (see notes [below](#launch-intent))
`smart_style_url` | `"https://ehr/styles/smart_v1.json"`| String URL where the host's style parameters can be retrieved (for apps that support [styling](#styling))
`tenant` | `"2ddd6c3a-8e9a-44c6-a305-52111ad302a2"`| String conveying an opaque identifier for the healthcare organization that is invoking the app.

##### Notes on launch context parameters

<h5 id="launch-intent"><b>App Launch Intent</b> (optional)</h5>
`intent`: Some SMART apps might offer more than one context or user interface
that can be accessed during the SMART launch. The optional `intent` parameter
in the launch context provides a mechanism for the SMART host to communicate to
the client app which specific context should be displayed as the outcome of the
launch. This allows for closer integration between the host and client, so that
different launch points in the host UI can target specific displays within the
client app.

For example, a patient timeline app might provide three specific UI contexts,
and inform the SMART host (out of band, at app configuration time)  of the
`intent` values that can be used to launch the app directly into one of the
three contexts. The app might respond to `intent` values like:

* `summary-timeline-view` - A default UI context, showing a data summary
* `recent-history-timeline` - A history display, showing a list of entries
* `encounter-focused-timeline` - A timeline focused on the currently in-context encounter

If a SMART host provides a value that the client does not recognize, or does
not provide a value, the client app should display a default application UI
context.

Note:  *SMART makes no effort to standardize `intent` values*.  Intents simply
provide a mechanism for tighter custom integration between an app and a SMART
host. The meaning of intents must be negotiated between the app and the host.

###### SMART App Styling (experimental[^1])
{: #styling}
`smart_style_url`: In order to mimic the style of the SMART host more closely,
SMART apps can check for the existence of this launch context parameter and
download the JSON file referenced by the URL value, if provided.

The URL should serve a "SMART Style" JSON object with one or more of the following properties:

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
hosts must return a new URL value in the `smart_style_url` launch context parameter if the contents
of this JSON is changed.

Style Property | Description
---------------|-------------
`color_background` | The color used as the background of the app.
`color_error` | The color used when UI elements need to indicate an area or item of concern or dangerous action, such as a button to be used to delete an item, or a display an error message.
`color_highlight` | The color used when UI elements need to indicate an area or item of focus, such as a button used to submit a form, or a loading indicator.
`color_modal_backdrop` | The color used when displaying a backdrop behind a modal dialog or window.
`color_success` | The color used when UI elements need to indicate a positive outcome, such as a notice that an action was completed successfully.
`color_text` | The color used for body text in the app.
`dim_border_radius` | The base corner radius used for UI element borders (0px results in square corners).
`dim_font_size` | The base size of body text displayed in the app.
`dim_spacing_size` | The base dimension used to space UI elements.
`font_family_body` | The list of typefaces to use for body text and elements.
`font_family_heading` | The list of typefaces to use for content heading text and elements.

SMART client apps that can adjust their styles should incorporate the above
property values into their stylesheets, but are not required to do so.

Optionally, if the client app detects a new version of the SMART Style object
(i.e. a new URL is returned the `smart_style_url` parameter), the client can
store the new property values and request approval to use the new values from
a client app stakeholder. This allows for safeguarding against poor usability
that might occur from the immediate use of these values in the client app UI.

### Scopes for requesting identity data

Some apps need to authenticate the clinical end-user. This can be accomplished
by requesting a pair of OpenID Connect scopes: `openid` and  `fhirUser`. A
client may also request `openid profile` instead of `openid fhirUser`, but the
`profile` claim is being deprecated in favor of `fhirUser`.

When these scopes are requested (and the request is granted), the app will
receive an [`id_token`](http://openid.net/specs/openid-connect-core-1_0.html#CodeIDToken)
that comes alongside the access token.

This token must be [validated according to the OIDC specification](http://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation).
To learn more about the user, the app should treat the `fhirUser` claim as the URL of
a FHIR resource representing the current user. This will be a resource of type
`Patient`, `Practitioner`, `RelatedPerson`, or `Person`.  Note that `Person` is only used if the other resource type do not apply to the current user, for example, the "authorized representative" for >1 patients.

The [OpenID Connect Core specification](http://openid.net/specs/openid-connect-core-1_0.html)
describes a wide surface area with many optional capabilities. To be considered compatible
with the SMART's `sso-openid-connect` capability, the following requirements apply:

 * Response types: The EHR SHALL support the Authorization Code Flow, with the request parameters as defined in [this guide](index.html). Support is not required for parameters that OIDC lists as optional (e.g. `id_token_hint`, `acr_value`), but EHRs are encouraged to review these optional parameters.

 * Public Keys Published as SHALL Keys: The EHR SHALL publish public keys as bare JWK keys (which MAY also be accompanied by X.509 representations of those keys).

 * Claims: The EHR SHALL support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the `openid` and `fhirUser` scopes.  Some EHRs may use the `profile` claim as an alias for `fhirUser`, and to preserve compatibility, these EHRs should continue to support this claim during a deprecation phase.

* Signed ID Token: The EHR SHALL support Signing ID Tokens with RSA SHA-256.

* A SMART app SHALL NOT pass the `auth_time` claim or `max_age` parameter to a server that does not support receiving them.

Note that support for the following features is optional:

 * `claims` parameters on the authorization request
 * Request Objects on the authorization request
 * UserInfo endpoint with claims exposed to clients

### Scopes for requesting a refresh token

To request a `refresh_token` that can be used to obtain a new access token
after the current access token expires, add one of the following scopes:

Scope              | Grants
-------------------|-------
`online_access`    | Request a `refresh_token` that can be used to obtain a new access token to replace an expired one, and that will be usable for as long as the end-user remains online.
`offline_access`   | Request a `refresh_token` that can be used to obtain a new access token to replace an expired token, and that will remain usable for as long as the authorization server and end-user will allow, regardless of whether the end-user is online.

### Extensions

Additional context parameters and scopes can be used as extensions using the following namespace conventions:

- use a *full URI* that you control (e.g. http://example.com/scope-name)
- use any string starting with `__` (two underscores)

### Steps for using an ID token

 1. Examine the ID token for its "issuer" property
 2. Perform a `GET {issuer}/.well-known/openid-configuration`
 3. Fetch the server's JSON Web Key by following the "jwks_uri" property
 4. Validate the token's signature against the public key from step #3
 5. Extract the `fhirUser` claim and treat it as the URL of a FHIR resource

### Worked examples

- Worked Python example: [rendered](worked_example_id_token.html)

### Appendix: URI representation of scopes

In some circumstances - for example, exchanging what scopes users are allowed to have, or sharing what they did choose), the scopes must be represented as URIs. When this is done, the standard URI is to prefix the SMART scopes with  http://smarthealthit.org/fhir/scopes/, so that a scope would be `http://smarthealthit.org/fhir/scopes/patient/*.read`.

openID scopes have a URI prefix of http://openid.net/specs/openid-connect-core-1_0#

---

<br />

[^1]: Section is marked as "experimental" to indicate that there may be future backwards-incompatible changes to the style document pointed to by the `smart_style_url`.
