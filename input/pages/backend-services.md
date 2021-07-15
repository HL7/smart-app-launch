## SMART Backend Services

### Profile Audience and Scope

This profile is intended to be used by developers of backend services (clients)
that autonomously (or semi-autonomously) need to access resources from FHIR
servers that have pre-authorized defined scopes of access.  This specification
handles use cases complementary to the [SMART App Launch
protocol](http://www.hl7.org/fhir/smart-app-launch/).  Specifically, this
profile describes the runtime process by which the client acquires an access
token that can be used to retrieve FHIR resources.  This specification is
designed to work with [FHIR Bulk Data Access](http://hl7.org/fhir/uv/bulkdata/),
but is not restricted to use for retrieving bulk data; it may be used to connect
to any FHIR API endpoint, including both synchronous and asynchronous access.

#### **Use this profile** when the following conditions apply:

* The target FHIR authorization server can register the client and pre-authorize access to a
defined set of FHIR resources.
* The client may run autonomously, or with user interaction that does not
include access authorization.
* The client supports `client-confidential-asymmetric` authentication (TODO: link)
* No compelling need exists for a user to authorize the access at runtime.

*Note* See Also:
The FHIR specification includes a set of [security considerations](http://hl7.org/fhir/security.html) including security, privacy, and access control. These considerations apply to diverse use cases and provide general guidance for choosing among security specifications for particular use cases.

#### Examples

* An analytics platform or data warehouse that periodically performs a bulk data
import from an electronic health record system for analysis of
a population of patients.

* A lab monitoring service that determines which patients are currently
admitted to the hospital, reviews incoming laboratory results, and generates
clinical alerts when specific trigger conditions are met.  Note that in this
example, the monitoring service may be a backend client to multiple servers.

* A data integration service that periodically queries the EHR for newly
registered patients and synchronizes these with an external database

* A utilization tracking system that queries an EHR every minute for
bed and room usage and displays statistics on a wall monitor.

* Public health surveillance studies that do not require real-time exchange of data.

### Underlying Standards

* [HL7 FHIR RESTful API](http://www.hl7.org/fhir/http.html)
* [RFC5246, The Transport Layer Security Protocol, V1.2](https://tools.ietf.org/html/rfc5246)
* [RFC6749, The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
* [RFC7515, JSON Web Signature](https://tools.ietf.org/html/rfc7515)
* [RFC7517, JSON Web Key](https://www.rfc-editor.org/rfc/rfc7517.txt)
* [RFC7518, JSON Web Algorithms](https://tools.ietf.org/html/rfc7518)
* [RFC7519, JSON Web Token (JWT)](https://tools.ietf.org/html/rfc7519)
* [RFC7521, Assertion Framework for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7521)
* [RFC7523, JSON Web Token (JWT) Profile for OAuth 2.0 Client Authentication and Authorization Grants](https://tools.ietf.org/html/rfc7523)
* [RFC7591, OAuth 2.0 Dynamic Client Registration Protocol](https://tools.ietf.org/html/rfc7591)

### Conformance Language
This specification uses the conformance verbs SHALL, SHOULD, and MAY as defined
in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt). Unlike RFC 2119, however,
this specification allows that different applications may not be able to
interoperate because of how they use optional features. In particular:

1.  SHALL: an absolute requirement for all implementations
2.  SHALL NOT: an absolute prohibition against inclusion for all implementations
3.  SHOULD/SHOULD NOT: A best practice or recommendation to be considered by
implementers within the context of their particular implementation; there may
be valid reasons to ignore an item, but the full implications must be understood
and carefully weighed before choosing a different course
4.  MAY: This is truly optional language for an implementation; can be included or omitted as the implementer decides with no implications


### Registering a SMART Backend Service (communicating public keys)

Before a SMART client can run against a FHIR server, the client SHALL register
with the server by following the registration steps described in `client-confidential-symmetric` authentication (TODO: link).

### Obtaining an Access Token

By the time a client has been registered with the FHIR authorization server, the key
elements of organizational trust will have been established. That is, the
client will be considered "pre-authorized" to access FHIR resources.
Then, at runtime, the client will need to obtain an access token in
order to retrieve FHIR resources as pre-authorized. Such access tokens are
issued by the FHIR authorization server, in accordance with the [OAuth 2.0
Authorization Framework, RFC6749](https://tools.ietf.org/html/rfc6749).  

Because the authorization scope is limited to protected resources previously
arranged with the FHIR authorization server, the client credentials grant flow,
as defined in [Section 4.4 of RFC6749](https://tools.ietf.org/html/rfc6749#page-40),
may be used to request authorization.  Use of the client credentials grant type
requires that the client SHALL be a "confidential" client capable of
protecting its authentication credential.  

This specification describes requirements for requesting an access token
through the use of an OAuth 2.0 client credentials flow, with a [JWT
assertion](https://tools.ietf.org/html/rfc7523) as the
client's authentication mechanism. The exchange, as depicted below, allows the
client to authenticate itself to the FHIR authorization server and to request a short-lived
access token in a single exchange.

To begin the exchange, the client SHALL use the [Transport Layer Security
(TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246) or a more recent version of TLS to
authenticate the identity of the FHIR authorization server and to establish an encrypted,
integrity-protected link for securing all exchanges between the client
and the FHIR authorization server's token endpoint.  All exchanges described herein between the client
and the FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS .


#### Protocol details

Before a client can request an access token, it generates a one-time-use
authentication JWT as described in `client-confidential-symmetric`
authentication (TODO: link).  After generating this authentication JWT, the client
requests an access token via HTTP `POST` to the FHIR authorization server's
token endpoint URL, using content-type `application/x-www-form-urlencoded` with
the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The scope of access requested. See note about scopes below</td>
    </tr>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>client_credentials</code></td>
    </tr>
    <tr>
      <td><code>client_assertion_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>urn:ietf:params:oauth:client-assertion-type:jwt-bearer</code></td>
    </tr>
    <tr>
      <td><code>client_assertion</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Signed authentication JWT value (see above)</td>
    </tr>
  </tbody>
</table>

### Scopes

The client is pre-authorized by the server: at registration time or out of band,
it is given the authority to access certain data. The client then includes a set
of scopes in the access token request, which causes the server to apply
additional access restrictions following the [SMART Scopes
syntax](scopes-and-launch-context.html).  For Backend Services, requested scopes
will be `system/` scopes (for example `system/Observation.rs`, which requests an
access token capable of reading all Observations that the client has been
pre-authorized to access).


### Enforcing Authorization

There are several cases where a client might ask for data that the server cannot or will not return:
* Client explicitly asks for data that it is not authorized to see (e.g. a client asks for Observation resources but has scopes that only permit access to Patient resources). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server does not support (e.g., a client asks for Practitioner resources but the server does not support FHIR access to Practitioner data). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server supports and that appears consistent with its access scopes -- but some additional out-of-band rules/policies/restrictions prevents the client from being authorized to see these data. In this case, the server MAY withhold certain results from the response, and MAY indicate to the client that results were withheld by including OperationOutcome information in the "error" array for the response as a partial success.

Rules regarding circumstances under which a client is required to obtain and present an access token along with a request are based on risk-management decisions that each FHIR resource service needs to make, considering the workflows involved, perceived risks, and the organization’s risk-management policies.  Refresh tokens SHOULD NOT be issued.


### FHIR Authorization Server Obligations

#### Signature Verification

The FHIR authorization server validates a client's authentication JWT according to the `client-confidential-asymmetric` authentication profile (TODO: link).

#### Issuing Access Tokens

Once the client has been authenticated, the FHIR authorization server SHALL
mediate the request to assure that the scope requested is within the scope pre-authorized
to the client.

If the access token request is valid and authorized, the FHIR authorization server
SHALL issue an access token in response.  The access token response SHALL be a JSON object with
the following properties:

<table class="table">
  <thead>
    <th colspan="3">Access token response: property names</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The access token issued by the FHIR authorization server.</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>bearer</code>.</td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The lifetime in seconds of the access token. The recommended value is <code>300</code>, for a five-minute token lifetime.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this can be different from the scopes requested by the app.</td>
    </tr>
  </tbody>
</table>

To minimize risks associated with token redirection, the scope of each access token SHOULD encompass, and be limited to, the resources requested. Access tokens issued under this profile SHALL be short-lived; the `expires_in`
value SHOULD NOT exceed `300`, which represents an expiration-time of five minutes.

### Worked example

TODO: rationalize examples into an examples.html overview page

TODO: include content from https://github.com/HL7/bulk-data/blob/b930134d797e27201f5669de05b149e202d562d7/input/pagecontent/authorization.md#presenting-an-access-token-to-fhir-api