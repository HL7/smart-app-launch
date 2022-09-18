The SMART's App Launch specification enables apps to launch and securely interact with EHRs.
The specification can be described as a set of capabilities and a given SMART on FHIR server implementation
may implement a subset of these.  The methods of declaring a server's SMART authorization endpoints and launch capabilities are described in the sections below.

### SMART on FHIR OAuth authorization Endpoints and Capabilities

The server SHALL convey the FHIR OAuth authorization endpoints and any *optional* SMART Capabilities it supports using a [Well-Known Uniform Resource Identifiers (URIs)](#using-well-known) JSON file. (In previous versions of SMART, some of these details were also conveyed in a server's CapabilityStatement; this mechanism is now deprecated.)


#### Capability Sets

A *Capability Set* combines individual capabilities to enable a specific use-case. A SMART on FHIR server SHOULD support one or more *Capability Set*s. Unless otherwise noted, each capability listed is required to satisfy a *Capability Set*. Any individual SMART server will publish a granular list of its capabilities; from this list a client can determine which of these Capability Sets are supported:

External implementation guides MAY define additional capabilities to be discovered through this same mechanism. IGs published by HL7 MAY use simple strings to represent additional capabilities (e.g., `example-new-capability`); IGs published by other organizations SHALL use full URIs to represent additional capabilities (e.g., `http://sdo.example.org/example-new-capability`).

##### Patient Access for Standalone Apps
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-standalone-patient`
1. `permission-patient`

#####  Patient Access for EHR Launch (i.e. from Portal)
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-ehr-patient`
1. `permission-patient`

#####  Clinician Access for Standalone
1. `launch-standalone`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `permission-user`
1. `permission-patient`

#####  Clinician Access for EHR Launch
1. `launch-ehr`
1. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
1. `context-ehr-patient` support
1. `context-ehr-encounter` support
1. `permission-user`
1. `permission-patient`

#### Capabilities

To promote interoperability, the following SMART on FHIR *Capabilities* have been defined. A given set of these capabilities is combined to support a specific use, a *Capability Set*.

##### Launch Modes

* `launch-ehr`: support for SMART's EHR Launch mode  
* `launch-standalone`: support for SMART's Standalone Launch mode

##### Authorization Methods

* `authorize-post`: support for POST-based authorization

##### Client Types

* `client-public`: support for SMART's public client profile (no client authentication)  
* `client-confidential-symmetric`: support for SMART's symmetric confidential client profile ("client secret" authentication). See [Client Authentication: Symmetric](client-confidential-symmetric.html).
* `client-confidential-asymmetric`: support for SMART's asymmetric confidential client profile ("JWT authentication"). See [Client Authentication: Asymmetric](client-confidential-asymmetric.html).

##### Single Sign-on

* `sso-openid-connect`: support for SMART's OpenID Connect profile

##### Launch Context

The following capabilities convey that a SMART on FHIR server is capable of providing context
to an app at launch time.

###### Lauch Context for UI Integration

These capabilities only apply during an EHR Launch, and `context-style` only for an embedded EHR Launch.

* `context-banner`: support for "need patient banner" launch context (conveyed via `need_patient_banner` token parameter)
* `context-style`: support for "SMART style URL" launch context (conveyed via `smart_style_url` token parameter). This capability is deemed *experimental*.

###### Launch Context for EHR Launch

When a SMART on FHIR server supports the launch of an app from _within_ an
existing user session ("EHR Launch"), the server has an opportunity to pass
existing, already-established context (such as the current patient ID) through
to the launching app. Using the following capabilities, a server declares its
ability to pass context through to an app at launch time:

* `context-ehr-patient`: support for patient-level launch context (requested by `launch/patient` scope, conveyed via `patient` token parameter)
* `context-ehr-encounter`: support for encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token parameter)

###### Launch Context for Standalone Launch

When a SMART on FHIR server supports the launch of an app from _outside_ an
existing user session ("Standalone Launch"), the server may be able to
proactively resolve new context to help establish the details required for an
app launch. For example, an external app may request that the SMART on FHIR
server should work with the end-user to establish a patient context before
completing the launch.

* `context-standalone-patient`: support for patient-level launch context (requested by `launch/patient` scope, conveyed via `patient` token parameter)
* `context-standalone-encounter`: support for encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token parameter)

##### Permissions

* `permission-offline`: support for refresh tokens (requested by `offline_access` scope)
* `permission-online`: support for refresh tokens (requested by `online_access` scope)
* `permission-patient`: support for patient-level scopes (e.g., `patient/Observation.rs`)
* `permission-user`: support for user-level scopes (e.g., `user/Appointment.rs`)
* `permission-v1`: support for SMARTv1 scope syntax (e.g., `patient/Observation.read`)
* `permission-v2`: support for SMARTv2 granular scope syntax (e.g., `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|vital-signs`)

<br />


### FHIR Authorization Endpoint and Capabilities Discovery using a Well-Known Uniform Resource Identifiers (URIs)
{: #using-well-known}

The authorization endpoints accepted by a FHIR resource server are exposed as a Well-Known Uniform Resource Identifiers (URIs) [(RFC5785)](https://datatracker.ietf.org/doc/html/rfc5785) JSON document.

FHIR endpoints requiring authorization SHALL serve a JSON document at the location formed by appending `/.well-known/smart-configuration` to their base URL.
Contrary to RFC5785 Appendix B.4, the `.well-known` path component may be appended even if the FHIR endpoint already contains a path component.

Responses for `/.well-known/smart-configuration` requests SHALL be JSON, regardless of `Accept` headers provided in the request.

* clients MAY omit an `Accept` header
* servers MAY ignore any client-supplied `Accept` headers
* servers SHALL respond with `application/json`

All endpoint URLs in the response document SHALL be absolute URLs. Clients
encountering relative endpoint URLs (e.g., in the context of legacy or
non-conformant servers) SHOULD evaluate them relative to the FHIR Server Base
URL following [RFC1808](https://datatracker.ietf.org/doc/html/rfc1808#section-4).
For example, in a browser context the absolute URL could be determined via 
`new URL(relativeUrl, fhirBaseUrl).toString()` .


<a id="example-request">

#### Sample Request

Sample requests:

##### Base URL "fhir.ehr.example.com"

```
GET /.well-known/smart-configuration HTTP/1.1
Host: fhir.ehr.example.com
```

##### Base URL "www.ehr.example.com/apis/fhir"

```
GET /apis/fhir/.well-known/smart-configuration HTTP/1.1
Host: www.ehr.example.com
```

#### Response

A JSON document must be returned using the `application/json` mime type.

##### Metadata
- `issuer`: **CONDITIONAL**, String conveying this system's OpenID Connect Issuer URL. Required if the server's capabilities include `sso-openid-connect`; otherwise, omitted.
- `jwks_uri`: **CONDITIONAL**, String conveying this system's JSON Web Key Set URL. Required if the server's capabilities include `sso-openid-connect`; otherwise, optional.
- `authorization_endpoint`: **REQUIRED**, URL to the OAuth2 authorization endpoint.
- `grant_types_supported`: **REQUIRED**, Array of grant types supported at the token endpoint. The options are "authorization_code" (when SMART App Launch is supported) and "client_credentials" (when SMART Backend Services is supported).
- `token_endpoint`: **REQUIRED**, URL to the OAuth2 token endpoint.
- `token_endpoint_auth_methods_supported`: **OPTIONAL**, array of client authentication methods supported by the token endpoint. The options are "client_secret_post", "client_secret_basic", and "private_key_jwt".
- `registration_endpoint`: **OPTIONAL**, If available, URL to the OAuth2 dynamic registration endpoint for this FHIR server.
- `scopes_supported`: **RECOMMENDED**, Array of scopes a client may request. See [scopes and launch context](scopes-and-launch-context.html#quick-start). The server SHALL support all scopes listed here; additional scopes MAY be supported (so clients should not consider this an exhaustive list).
- `response_types_supported`: **RECOMMENDED**, Array of OAuth2 `response_type` values that are supported.  Implementers can refer to `response_type`s defined in OAuth 2.0 ([RFC 6749](https://datatracker.ietf.org/doc/html/rfc6749)) and in [OIDC Core](https://openid.net/specs/openid-connect-core-1_0.html#Authentication).
- `management_endpoint`: **RECOMMENDED**, URL where an end-user can view which applications currently have access to data and can make adjustments to these access rights.
- `introspection_endpoint` :  **RECOMMENDED**, URL to a server's introspection endpoint that can be used to validate a token.
- `revocation_endpoint` :  **RECOMMENDED**, URL to a server's revoke endpoint that can be used to revoke a token.
- `capabilities`: **REQUIRED**, Array of strings representing SMART capabilities (e.g., `sso-openid-connect` or `launch-standalone`) that the server supports.
- `code_challenge_methods_supported`: **REQUIRED**, Array of PKCE code challenge methods supported. The `S256` method SHALL be included in this list, and the `plain` method SHALL NOT be included in this list.


<a id="example-response">

#### Sample Response

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "issuer": "https://ehr.example.com",
  "jwks_uri": "https://ehr.example.com/.well-known/jwks.json",
  "authorization_endpoint": "https://ehr.example.com/auth/authorize",
  "token_endpoint": "https://ehr.example.com/auth/token",
  "token_endpoint_auth_methods_supported": [
    "client_secret_basic",
    "private_key_jwt"
  ],
  "grant_types_supported": [
    "authorization_code",
    "client_credentials"
  ],
  "registration_endpoint": "https://ehr.example.com/auth/register",
  "scopes_supported": ["openid", "profile", "launch", "launch/patient", "patient/*.rs", "user/*.rs", "offline_access"],
  "response_types_supported": ["code"],
  "management_endpoint": "https://ehr.example.com/user/manage",
  "introspection_endpoint": "https://ehr.example.com/user/introspect",
  "revocation_endpoint": "https://ehr.example.com/user/revoke",
  "code_challenge_methods_supported": ["S256"],
  "capabilities": [
    "launch-ehr",
    "permission-patient",
    "permission-v2",
    "client-public",
    "client-confidential-symmetric",
    "context-ehr-patient",
    "sso-openid-connect"
  ]
}
```

