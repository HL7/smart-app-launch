### Profile Audience and Scope

This profile is intended to be used by developers of backend services (clients)
that autonomously (or semi-autonomously) need to access resources from FHIR
servers that have pre-authorized defined scopes of access.  This specification
handles use cases complementary to the [SMART App Launch
protocol](app-launch.html).  Specifically, this
profile describes the runtime process by which the client acquires an access
token that can be used to retrieve FHIR resources.  This specification is
designed to work with [FHIR Bulk Data Access](http://hl7.org/fhir/uv/bulkdata/),
but is not restricted to use for retrieving bulk data; it may be used to connect
to any FHIR API endpoint, including both synchronous and asynchronous access.

#### Use this profile when the following conditions all apply:

* The target FHIR authorization server can register the client and pre-authorize access to a
defined set of FHIR resources.
* The client may run autonomously, or with user interaction that does not
include access authorization.
* The client supports [`client-confidential-asymmetric` authentication](client-confidential-asymmetric.html)
* No compelling need exists for a user to authorize the access at runtime.

Note that the FHIR specification includes a set of [security considerations](http://hl7.org/fhir/security.html) including security, privacy, and access control. These considerations apply to diverse use cases and provide general guidance for choosing among security specifications for particular use cases.

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

See section [References](references.html).

### Top-level steps for Backend Services Authorization

<div>{% include overview-backend-services.svg %}</div>
<br clear="all"/>

1. [Register Backend Service](#step-1-register) (*one-time step*, can be out-of-band)
2. [Retrieve .well-known/smart-configuration](#step-2-discovery)
3. [Obtain access token](#step-3-access-token)
4. [Access FHIR API](#step-4-fhir-api)


<a id="step-1-register"></a>

### Register SMART Backend Service (communicating public keys)

Before a SMART client can run against a FHIR server, the client SHALL register
with the server by following the [registration steps described in `client-confidential-asymmetric` authentication](client-confidential-asymmetric.html#registering-a-client-communicating-public-keys).

<a id="step-2-discovery"></a>

### Retrieve `.well-known/smart-configuration`

In order to request authorization to access FHIR resources, the app discovers the EHR FHIR server's SMART configuration metadata, including OAuth `token` endpoint URL.

#### Request
The app issues an HTTP GET with an `Accept` header supporting `application/json` to retrieve the SMART configuration file.

#### Response

Servers respond with a discovery response that meets [discovery requirements described in `client-confidential-asymmetric` authentication](client-confidential-asymmetric.html#discovery-requirements).

#### Example Request and Response

For a full example, see [example request and response](example-backend-services.html#step-2-discovery).

<a id="step-3-access-token"></a>

### Obtain access token

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
client's authentication mechanism. The exchange, as depicted above, allows the
client to authenticate itself to the FHIR authorization server and to request a short-lived
access token in a single exchange.


#### Request

To begin the exchange, the client SHALL use the [Transport Layer Security
(TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246) or a more recent version of TLS to
authenticate the identity of the FHIR authorization server and to establish an encrypted,
integrity-protected link for securing all exchanges between the client
and the FHIR authorization server's token endpoint.  All exchanges described herein between the client
and the FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS .


Before a client can request an access token, it generates a one-time-use
authentication JWT [as described in `client-confidential-asymmetric`
authentication](client-confidential-asymmetric.html#authenticating-to-the-token-endpoint).
After generating this authentication JWT, the client
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

##### Scopes

The client is pre-authorized by the server. In other words, by the time a client
initiates an access token request, the server has already associated the client
with the authority to access certain data. The client then includes a set
of scopes in the access token request, which causes the server to apply
additional access restrictions following the [SMART Scopes
syntax](scopes-and-launch-context.html).  For Backend Services, requested scopes
will be `system/` scopes (for example `system/Observation.rs`, which requests an
access token capable of reading all Observations that the client has been
pre-authorized to access). The use of Backend Services with `user/` and
`patient/` scopes is not prohibited, but would require out-of-band coordination
to establish context (e.g., to establish which user or patient applies).

#### Response

##### Enforce Authorization

There are several cases where a client might ask for data that the server cannot or will not return:
* Client explicitly asks for data that it is not authorized to see (e.g., a client asks for Observation resources but has scopes that only permit access to Patient resources). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server does not support (e.g., a client asks for Practitioner resources but the server does not support FHIR access to Practitioner data). In this case a server SHOULD respond with a failure to the initial request.
* Client explicitly asks for data that the server supports and that appears consistent with its access scopes -- but some additional out-of-band rules/policies/restrictions prevents the client from being authorized to see these data. In this case, the server MAY withhold certain results from the response, and MAY indicate to the client that results were withheld by including OperationOutcome information in the "error" array for the response as a partial success.

Rules regarding circumstances under which a client is required to obtain and present an access token along with a request are based on risk-management decisions that each FHIR resource service needs to make, considering the workflows involved, perceived risks, and the organization’s risk-management policies.  Refresh tokens SHOULD NOT be issued.

##### Validate Authentication JWS

The FHIR authorization server validates a client's authentication JWT according to the `client-confidential-asymmetric` authentication profile. [See JWT validation rules](client-confidential-asymmetric.html#signature-verification).


##### Evaluate Requested Access

Once the client has been authenticated, the FHIR authorization server SHALL
mediate the request to assure that the scope requested is within the scope pre-authorized
to the client.

##### Issue Access Token

If an error is encountered during the authorization process, the FHIR authorization server SHALL
respond with the appropriate error message defined in [Section 5.2 of the OAuth 2.0 specification](https://tools.ietf.org/html/rfc6749#page-45).  The FHIR authorization server SHOULD include an `error_uri` or `error_description` as defined in OAuth 2.0.

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

To minimize risks associated with token redirection, the scope of each access token SHOULD encompass, and be limited to, the resources requested. Access tokens issued under this profile SHALL be short-lived; the `expires_in` value SHOULD NOT exceed `300`, which represents an expiration-time of five minutes. To establish longer-term access, clients can request new access tokens as needed.

#### Example Token Request and Response

For a full example, see [example token request and response](example-backend-services.html#step-3-access-token).

<a id="step-4-fhir-api"></a>

### Access FHIR API

With a valid access token, the app can access protected FHIR data by issuing a
FHIR API call to the FHIR endpoint on the FHIR resource server.

#### Request

From the access token response, an app has received an OAuth2 bearer-type access token (`access_token` property) that can be used to fetch clinical data.  The app issues a request that includes an
`Authorization` header that presents the `access_token` as a "Bearer" token:

{% raw %}
    Authorization: Bearer {{access_token}}
{% endraw %}

(Note that in a real request, `{% raw %}{{access_token}}{% endraw %}`{:.language-text} is replaced
with the actual token value.)

#### Response

The resource server SHALL validate the access token and ensure that it has not expired and that its scope covers the requested resource. The method used by the EHR to validate the access token is beyond the scope of this specification but generally involves an interaction or coordination between the EHR’s resource server and the authorization server.

On occasion, a Backend Service may receive a FHIR resource that contains a “reference” to a resource hosted on a different resource server.  The Backend Service SHOULD NOT blindly follow such references and send along its access_token, as the token may be subject to potential theft.   The Backend Service SHOULD either ignore the reference, or initiate a new request for access to that resource.

#### Example Request and Response

For a full example, see [example FHIR API request and response](example-backend-services.html#step-4-fhir-api).
