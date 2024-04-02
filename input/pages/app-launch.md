The SMART App Launch Framework connects third-party applications to Electronic
Health Record data, allowing apps to launch from inside or outside the user
interface of an EHR system. The framework supports apps for use by clinicians,
patients, and others via a PHR, Patient Portal, or any FHIR system where a user can launch an app. It provides a reliable, secure authorization protocol for
a variety of app architectures, including apps that run on an end-user's device
as well as apps that run on a secure server.
The Launch Framework supports four key use cases:

1. Patient apps that launch standalone
2. Patient apps that launch from a portal
3. Provider apps that launch standalone
4. Provider apps that launch from a portal

These use cases support apps that perform data visualization, data collection,
clinical decision support, data sharing, case reporting, and many other
functions.

For additional functionality defined in this implementation guide, see section
[Overview](index.html).

### Profile audience and scope

This profile on OAuth 2.0 is intended to be used by developers of apps that need to access user identity information or other FHIR resources by requesting authorization from OAuth 2.0-compliant authorization servers. It is compatible with FHIR R2 (DSTU2) and later; this publication includes explicit definitions for FHIR R4 and R4B.

OAuth 2.0 authorization servers are configured to mediate access based on
a set of rules configured to enforce institutional policy, which may
include requesting end-user authorization.  This profile
does not dictate the institutional policies that are implemented in the
authorization server.

The profile defines a method through which an app requests
authorization to access a FHIR resource, and then uses that authorization
to retrieve the resource.  Synchronization of patient context is not addressed;
for use cases that require context synchronization (e.g., learning about when
the in-context patient changes within an EHR session) see
[FHIRcast](https://fhircast.org).  In other words, if the patient chart is
changed during the session, the application will not inherently be updated.

Security mechanisms such as those mandated by HIPAA in the US (end-user
authentication, session time-out, security auditing, and accounting of
disclosures) are outside the scope of this profile.

This profile provides a mechanism to *delegate* an entity's permissions (e.g., a user's permissions) to a 3rd-party app. The profile includes mechanisms to delegate a limited subset of an entity's permissions (e.g., only sharing access to certain data types). However, this profile does not model the permissions that the entity has in the first place (e.g., it provides no mechanism to specify that a given entity should or should not be able to access specific records in an EHR). Hence, this profile is designed to work on top of an EHR's existing user and permissions management system, enabling a standardized mechanism for delegation.


### Security and Privacy Considerations

#### App protection

The app is responsible for protecting itself from potential misbehaving or
malicious values passed to its redirect URL (e.g., values injected with
executable code, such as SQL) and for protecting authorization codes, access
tokens, and refresh tokens from unauthorized access and use.  The app
developer must be aware of potential threats, such as malicious apps running
on the same platform, counterfeit authorization servers, and counterfeit
resource servers, and implement countermeasures to help protect both the app
itself and any sensitive information it may hold. For background, see the
[OAuth 2.0 Threat Model and Security
Considerations](https://tools.ietf.org/html/rfc6819).

Specific requirements are:

* Apps SHALL ensure that when protocol steps include transmission of sensitive
information (authentication secrets, authorization codes, tokens), transmission
is ONLY to authenticated servers, over TLS-secured channels.

* Apps SHALL generate an unpredictable `state` parameter for each user
session; SHALL include `state` with all authorization requests; and SHALL
validate the `state` value for any request sent to its redirect URL.

* An app SHALL NOT execute untrusted user-supplied inputs as code.

* An app SHALL NOT forward values passed back to its redirect URL to any
other arbitrary or user-provided URL (a practice known as an “open
redirector”).

* An app SHALL NOT store bearer tokens in cookies that are transmitted
as clear text.

* Apps SHOULD persist tokens and other sensitive data in app-specific
storage locations only, and SHOULD NOT persist them in
system-wide-discoverable locations.

#### Support for "public" and "confidential" apps

Within this profile we differentiate between the two types of apps defined in the [OAuth 2.0 specification: confidential and public](https://tools.ietf.org/html/rfc6749#section-2.1). The differentiation is based upon whether the execution environment within which the app runs
enables the app to protect secrets.   Pure client-side apps
(for example, HTML5/JS browser-based apps, iOS mobile
apps, or Windows desktop apps) can provide adequate security, but they may be unable to "keep a secret" in the OAuth2 sense.  In other words, any "secret" key, code, or
string that is statically embedded in the app can potentially be extracted by an end-user
or attacker. Hence security for these apps cannot depend on secrets embedded at
install-time.

For strategies and best practices to protecting a client secret refer to:

- OAuth 2.0 Threat Model and Security Considerations: [4.1.1. Threat: Obtaining Client Secrets](https://tools.ietf.org/html/rfc6819#section-4.1.1)
- OAuth 2.0 for Native Apps: [8.5. Client Authentication](https://tools.ietf.org/html/draft-ietf-oauth-native-apps-12#section-8.5)
- [OAuth 2.0 Dynamic Client Registration Protocol](https://tools.ietf.org/html/rfc7591)

##### Determining the appropriate app type

To determine the appropriate app type, first answer the question "*is your app able to protect a secret?*"

* If "Yes", use a <span class="label label-primary">confidential app</span>
  * Example: App runs on a trusted server with only server-side access to the secret
  * Example: App is a native app that uses additional technology (such as dynamic client registration and universal `redirect_uris`) to protect the secret

* If "No",  use a <span class="label label-primary">public app</span>
  * Example: App is an HTML5 or JS in-browser app (including single-page applications) that would expose the secret in user space
  * Example: App is a native app that can only distribute a secret statically


#### Considerations for PKCE Support
All SMART apps SHALL support Proof Key for Code Exchange (PKCE).  PKCE is a standardized, cross-platform technique for clients to mitigate the threat of authorization code interception or injection. PKCE is described in [IETF RFC 7636](https://tools.ietf.org/html/rfc7636). SMART servers SHALL support the `S256` `code_challenge_method` and SHALL NOT support the `plain` method.

#### Considerations for Cross-Origin Resource Sharing (CORS) support
Servers that support purely browser-based apps SHALL enable [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) as follows:

1. For requests from any origin, CORS configuration permits access to the public discovery endpoints (`.well-known/smart-configuration` and `metadata`)
2. For requests from a client's registered origin(s), CORS configuration permits access to the token endpoint and to FHIR REST API endpoints 

#### Related reading

Implementers can review the [OAuth Security Topics](https://tools.ietf.org/html/draft-ietf-oauth-security-topics-16) guidance from IETF as a collection of Best Current Practices.

Some resources shared with apps following this IG may be considered [Patient Sensitive](http://hl7.org/fhir/security.html#Patient); implementers should review the Core FHIR Specification's [Security Page](http://hl7.org/fhir/security.html) for additional security and privacy considerations.

### SMART authorization & FHIR access: overview

An app can launch from within an existing session in an EHR, Patient Portal, or other FHIR system. Alternatively, it can launch as a standalone app.

In an <span class="label label-primary">EHR launch</span>, an opaque handle to
the EHR context is passed along to the app as part of the launch URL.  The app
later will include this handle as a request parameter when it requests
authorization to access resources. The server will provide the application with
EHR context based on this handle. Note that the complete URLs of
all apps approved for use by users of this EHR will have been registered with
the EHR authorization server.

In a <span class="label label-primary">standalone launch</span>, when the app
launches from outside an EHR session, the app can request context from the EHR
authorization server. The context will then be determined during the
authorization process as described below.

Once an app receives a launch request, it requests authorization to access FHIR resources by
instructing the browser to navigate to the EHR's authorization endpoint. Based
on pre-defined rules and possibly end-user authorization, the EHR authorization
server either grants the request by returning an authorization code to the app’s
redirect URL or denies the request. The app then exchanges the authorization
code for an access token. The app presents the access token to the EHR’s resource server to
access requested FHIR resources. If a refresh token is returned along with the
access token, the app may use it to request a new access token with the same
scope, once the old access token expires.

This specification is agnostic about how the EHR resource server and the EHR
authorization server are integrated, as long as they implement the required
app-facing behaviors

###  Top-level steps for SMART App Launch

The top-level steps for Smart App Launch are:

1. [Register App with EHR](#step-1-register) (*one-time step*, can be out-of-band)
2. Launch App:  [Standalone Launch](#step-2-launch-standalone) or [EHR Launch](#step-2-launch-ehr)
3. [Retrieve .well-known/smart-configuration](#step-3-discovery)
4. [Obtain authorization code](#step-4-authorization-code)
5. [Obtain access token](#step-5-access-token)
6. [Access FHIR API](#step-6-fhir-api)
7. [Refresh access token](#step-7-refresh)

The actors involved in each step and the order in which steps are used is illustrated in the figure below.

<div>{% include overview-app-launch.svg %}</div>
<br clear="all"/>


More detail on each of these steps is provided in the sections below.

<a id="step-1-register"></a>

### Register App with EHR

Before a SMART app can run against an EHR, the app must be registered with that
EHR's authorization service.  SMART does not specify a standards-based registration process, but we
encourage EHR implementers to consider the [OAuth 2.0 Dynamic Client
Registration Protocol](https://tools.ietf.org/html/rfc7591)
for an out-of-the-box solution.

*Note that this is a one-time setup step, and can occur out-of-band*.

#### Request

No matter how an app registers with an EHR's authorization service, at registration time **every SMART app SHALL**:

* Register zero or more fixed, fully-specified launch URL with the EHR's authorization server
* Register one or more fixed, fully-specified `redirect_uri`s with the EHR's authorization server. 

For confidential clients, additional registration-time requirements are defined based on the client authentication method.

* For asymmetric client authentication: a [JSON Web Key Set or JWSK URL](client-confidential-asymmetric.html#registering-a-client-communicating-public-keys) is established
* For symmetric client authentication: a [client secret](client-confidential-symmetric.html) is established

#### Response

The EHR confirms the app's registration parameters and communicates a `client_id` to the app.

<a id="step-2-launch"></a>
<a id="step-2-launch-standalone"></a>

### Launch App: Standalone Launch

In SMART's <span class="label label-primary">standalone
launch</span> flow, a user selects an app from outside the EHR
(for example, by tapping an app icon on a mobile phone home screen).  


#### Request
There is no explicit request associated with this step of the SMART App Launch process.  

#### Response
The app proceeds to the [next step](#step-3-discovery) of the SMART App Launch flow.

#### Examples

* [Public client](example-app-launch-public.html#step-2-launch)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-2-launch)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-2-launch)

<a id="step-2-launch-ehr"></a>

### Launch App: EHR Launch

In SMART's <span class="label label-primary">EHR launch</span> flow,
a user has established an EHR session and then decides to launch an app. This
could be a single-patient app that runs in the context of a patient record, or
a user-level app (like an appointment manager or a population dashboard).

#### Request
The EHR initiates a "launch sequence" by opening a new browser instance (or `iframe`)
pointing to the app's registered launch URL and passing some context.

The following parameters are included:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>iss</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

Identifies the EHR's FHIR endpoint, which the app can use to obtain
additional details about the EHR including its authorization URL.

      </td>
    </tr>
    <tr>
      <td><code>launch</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

      Opaque identifier for this specific launch and any EHR context associated
with it. This parameter must be communicated back to the EHR  at authorization
time by passing along a <code>launch</code> parameter (see example below).

      </td>
    </tr>
  </tbody>
</table>


##### *For example*
A launch might cause the browser to navigate to:

    Location: https://app/launch?iss=https%3A%2F%2Fehr%2Ffhir&launch=xyz123

Later, when the app prepares its [authorization request](#step-4-authorization-code), it includes
`launch` as a requested scope and includes a `launch={launch id}` URL
parameter echoing the value it received from the EHR in this
notification.

#### Response
The app proceeds to the [next step](#step-3-discovery) of the SMART App Launch flow.


<a id="step-3-discovery"></a>

### Retrieve `.well-known/smart-configuration`

In order to obtain launch context and request authorization to access FHIR
resources, the app discovers the EHR FHIR server's SMART configuration metadata,
including OAuth `authorization_endpoint` and `token_endpoint` URLs.

#### Request

The discovery URL is constructed by appending `.well-known/smart-configuration` to the FHIR Base URL.  The app issues an HTTP GET to the discovery URL with an `Accept` header supporting `application/json`.

#### Response
The EHR responds with a SMART configuration JSON document as described in the [Conformance](conformance.html) section.

#### Examples

* [Example request and response](conformance.html#example-request)


<a id="step-4-authorization-code"></a>

### Obtain authorization code

To proceed with a launch, the app constructs a request for an authorization code.

#### Request
The app supplies the following parameters to the EHR’s "authorize" endpoint.

*Note on PKCE Support: the EHR SHALL ensure that the `code_verifier` is present and valid when the code is exchanged for an access token.*

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>response_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>code</code>. </td>
    </tr>
    <tr>
      <td><code>client_id</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The client's identifier. </td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Must match one of the client's pre-registered redirect URIs.</td>
    </tr>
    <tr>
      <td><code>launch</code></td>
      <td><span class="label label-info">conditional</span></td>
      <td>When using the <span class="label label-primary">EHR Launch</span> flow, this must match the launch value received from the EHR. Omitted when using the <span class="label label-primary">Standalone Launch</span>.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

Must describe the access that the app needs, including scopes like
<code>patient/*.rs</code>, <code>openid</code> and <code>fhirUser</code> (if app
needs authenticated end-user identity) and either:

<ul>
<li> a <code>launch</code> value indicating that the app wants to receive already-established launch context details from the EHR </li>
<li> a set of launch context requirements in the form <code>launch/patient</code>, which asks the EHR to establish context on your behalf.</li>
</ul>

See the section on <a href="scopes-and-launch-context.html">SMART on FHIR Access
Scopes</a> for details.

      </td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td><span class="label label-success">required</span></td>
      <td>

An opaque value used by the client to maintain state between the request and
callback. The authorization server includes this value when redirecting the
user-agent back to the client. The parameter SHALL be used for preventing
cross-site request forgery or session fixation attacks.  The app SHALL use
an unpredictable value for the state parameter with at least 122 bits of
entropy (e.g., a properly configured random uuid is suitable).

      </td>
    </tr>
     <tr>
      <td><code>aud</code></td>
      <td><span class="label label-success">required</span></td>
      <td>
<p>
URL of the EHR resource server from which the app wishes to retrieve FHIR data.
This parameter prevents leaking a genuine bearer token to a counterfeit
resource server. (Note that in the case of an <span class="label label-primary">EHR launch</span>
flow, this <code>aud</code> value is the same as the launch's <code>iss</code> value.)
</p>

<p> Note that the <code>aud</code> parameter is semantically equivalent to the
<code>resource</code> parameter defined in <a
href="https://datatracker.ietf.org/doc/rfc8707">RFC8707</a>.  SMART's
<code>aud</code> parameter predates RFC8707 and we have decided not to rename it
for reasons of backwards compatibility. We might consider renaming SMART's
<code>aud</code> parameter in the future if implementer feedback indicates that
alignment would be valuable.</p>

For the current release, servers SHALL support the <code>aud</code> parameter
and MAY support a <code>resource</code> parameter as a synonym for
<code>aud</code>.

      </td>
    </tr>

    <tr>
      <td><code>code_challenge</code></td>
      <td><span class="label label-success">required</span></td>
      <td>This parameter is generated by the app and used for the code challenge, as specified by <a href="https://tools.ietf.org/html/rfc7636">PKCE</a>.  For example, when <code>code_challenge_method</code> is <code>'S256'</code>, this is the S256 hashed version of the <code>code_verifier</code> parameter.  See <a href="#considerations-for-pkce-support">considerations-for-pkce-support</a>.</td>
    </tr>


    <tr>
      <td><code>code_challenge_method</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Method used for the <code>code_challenge</code> parameter.  Example value: <code>S256</code>.  See <a href="#considerations-for-pkce-support">considerations-for-pkce-support</a>.</td>
    </tr>

  </tbody>
</table>

The app SHOULD limit its requested scopes to the minimum necessary (i.e.,
minimizing the requested data categories and the requested duration of access).

If the app needs to authenticate the identity of or retrieve information about
the end-user, it should include two OpenID Connect scopes:  `openid` and
`fhirUser`.   When these scopes are requested and the request is granted, the
app will receive an id_token along with the access token.  For full details,
see [SMART launch context parameters](scopes-and-launch-context.html).

The following requirements are adopted from [OpenID Connect Core 1.0 Specification section 3.1.2.1](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest):

* Authorization Servers SHALL support the use of the HTTP GET and POST methods at the Authorization Endpoint.
* Clients SHALL use either the HTTP GET or the HTTP POST method to send the Authorization Request to the Authorization Server.  If using the HTTP GET method, the request parameters are serialized using URI Query String Serialization.  If using the HTTP POST method, the request parameters are serialized using Form Serialization and the application/x-www-form-urlencoded content type.

###### *For example*
If an app needs demographics and observations for a single
patient and wants information about the current logged-in user, the app  can request:

* `patient/Patient.r`
* `patient/Observation.rs`
* `openid fhirUser`

If the app was launched from an EHR, the app adds a `launch` scope and a
`launch={launch id}` URL parameter echoing the value it received from the EHR
to be associated with the EHR context of this launch notification.

*Apps using the <span class="label label-primary">standalone launch</span> flow
won't have a `launch` id at this point.  These apps can declare launch context
requirements by adding specific scopes to the authorization request: for
example, `launch/patient` to indicate that the app needs a patient ID, or
`launch/encounter` to indicate it needs an encounter.  The EHR's "authorize"
endpoint will take care of acquiring the context it needs (making it available to the app).  
For example, if your app needs patient context, the EHR may
provide the end-user with a patient selection widget.  For full details, see <a
href="scopes-and-launch-context.html">SMART launch
context parameters</a>.*


The app then instructs the browser to navigate to the EHR's **authorization URL** as
determined above. For example to cause the browser to issue a `GET`:


```
Location: https://ehr/authorize?
            response_type=code&
            client_id=app-client-id&
            redirect_uri=https%3A%2F%2Fapp%2Fafter-auth&
            launch=xyz123&
            scope=launch+patient%2FObservation.rs+patient%2FPatient.rs+openid+fhirUser&
            state=98wrghuwuogerg97&
            aud=https://ehr/fhir
```

Alternatively, the following example shows one way for a client app to cause the browser to issue a `POST` using HTML and javascript:


```
<html>
  <body onload="javascript:document.forms[0].submit()">
    <form method="post" action="https://ehr/authorize">
      <input type="hidden" name="response_type" value="code"/>
      <input type="hidden" name="client_id" value="app-client-id"/>
      <input type="hidden" name="redirect_uri" value="https://app/after-auth"/>
      <input type="hidden" name="launch" value="xyz123"/>
      <input type="hidden" name="scope" value="launch patient/Observation.rs patient/Patient.rs openid fhirUser"/>
      <input type="hidden" name="state" value="98wrghuwuogerg97"/>
      <input type="hidden" name="aud" value="https://ehr/fhir"/>
    </form>
  </body>
</html>
```

#### Response

The authorization decision is up to the EHR authorization server which may request authorization from the end-user. The EHR authorization
server will enforce access rules based on local policies and optionally direct
end-user input.

The EHR decides whether to grant or deny access.  This decision is
communicated to the app when the EHR authorization server returns an
authorization code or, if denying access, an error response.  Authorization codes are short-lived, usually expiring
within around one minute.  The code is sent when the EHR authorization server
causes the browser to navigate to the app's <code>redirect_uri</code> with the
following URL parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>

      <td>

The authorization code generated by the authorization server. The
authorization code needs to expire shortly after it is issued to mitigate the
risk of leaks.

      </td>
    </tr>
    <tr>
      <td><code>state</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The exact value received from the client.</td>
    </tr>
  </tbody>
</table>

The app SHALL validate the value of the state parameter upon return to the
redirect URL and SHALL ensure that the state value is securely tied to the
user’s current session (e.g., by relating the state value to a session
identifier issued by the app).

###### *For example*

Based on the `client_id`, current EHR user, configured policy, and perhaps
direct user input, the EHR makes a decision to approve or deny access.  This
decision is communicated to the app by instructing the browser to navigate to the app's registered
`redirect_uri`. For example:

```
Location: https://app/after-auth?
  code=123abc&
  state=98wrghuwuogerg97
```

#### Examples

* [Public client](example-app-launch-public.html#step-4-authorization-code)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-4-authorization-code)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-4-authorization-code)



<a id="step-5-access-token"></a>

### Obtain access token

After obtaining an authorization code, the app trades the code for an access
token.

#### Request
The app issues an HTTP `POST` to the EHR authorization server's token endpoint URL using content-type `application/x-www-form-urlencoded` as described in
section 4.1.3 of [RFC6749](https://tools.ietf.org/html/rfc6749#section-4.1.3).

For <span class="label label-primary">public apps</span>, authentication is not required because a client with no secret cannot prove its
identity when it issues a call. (The end-to-end system can still be secure
because the client comes from a known, https-protected endpoint specified and
enforced by the redirect uri.)  For <span class="label label-primary">confidential
apps</span>, authentication is required. Confidential clients SHOULD use
[Asymmetric Authentication](client-confidential-asymmetric.html) if available, and
MAY use [Symmetric Authentication](client-confidential-symmetric.html).

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>authorization_code</code></td>
    </tr>
    <tr>
      <td><code>code</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Code that the app received from the authorization server</td>
    </tr>
    <tr>
      <td><code>redirect_uri</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The same redirect_uri used in the initial authorization request</td>
    </tr>
    <tr>
      <td><code>code_verifier</code></td>
      <td><span class="label label-success">required</span></td>
      <td>This parameter is used to verify against the <code>code_challenge</code> parameter previously provided in the authorize request.</td>
    </tr>
    <tr>
      <td><code>client_id</code></td>
      <td><span class="label label-info">conditional</span></td>
      <td>Required for <span class="label label-primary">public apps</span>. Omit for <span class="label label-primary">confidential apps</span>.</td>
    </tr>
  </tbody>
</table>

#### Response

The EHR authorization server SHALL return a JSON object that includes an access token
or a message indicating that the authorization request has been denied. The JSON structure
includes the following parameters:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The access token issued by the authorization server</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>Bearer</code></td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-info">recommended</span></td>
      <td>Lifetime in seconds of the access token, after which the token SHALL NOT be accepted by the resource server</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this can be different from the scopes requested by the app.</td>
    </tr>
    <tr>
      <td><code>id_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>Authenticated user identity and user details, if requested</td>
    </tr>
      <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>Token that can be used to obtain a new access token, using the same or a subset of the original authorization grants</td>
    </tr>
    <tr>
      <td><code>authorization_details {%include exp.html%}</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>{%include exp-span.html%}Additional details describing where this token can be used, and any per-location context (experimental; see <a href="#experimental-authorization-details-for-multiple-servers-exp">details</a>)</span></td>
    </tr>

  </tbody>
</table>

In addition, if the app was launched from within a patient context,
parameters to communicate the context values MAY BE included. For example,
a parameter like `"patient": "123"` would indicate the FHIR resource
https://[fhir-base]/Patient/123. Other context parameters may also
be available. For full details see the [SMART launch context parameters](scopes-and-launch-context.html) section.

The parameters are included in the entity-body of the HTTP response, as
described in section 5.1 of [RFC6749](https://tools.ietf.org/html/rfc6749).

The access token is a string of characters as defined in
[RFC6749](https://tools.ietf.org/html/rfc6749) and
[RFC6750](http://tools.ietf.org/html/rfc6750).  The token is essentially
a private message that the authorization server
passes to the FHIR Resource Server telling the FHIR server that the
"message bearer" has been authorized to access the specified resources.  
Defining the format and content of the access token is left up to the
organization that issues the access token and holds the requested resource.

The authorization server's response SHALL
include the HTTP "Cache-Control" response header field with a value
of "no-store," as well as the "Pragma" response header field with a
value of "no-cache."

The EHR authorization server decides what `expires_in` value to assign to an
access token and whether to issue a refresh token, as defined in section 1.5
of [RFC6749](https://tools.ietf.org/html/rfc6749#page-10), along with the
access token.  If the app receives a refresh token along with the access
token, it can exchange this refresh token for a new access token when the
current access token expires (see step 5 below).

Apps SHOULD store tokens in app-specific storage locations only, and not in
system-wide-discoverable locations.  Access tokens SHOULD have a valid
lifetime no greater than one hour.  Confidential
clients may be issued longer-lived tokens than public clients.

*A large range of threats to access tokens can be mitigated by digitally
signing the token as specified in [RFC7515](https://tools.ietf.org/html/rfc7515)
or by using a Message Authentication Code (MAC) instead.  Alternatively,
an access token can contain a reference to authorization information,
rather than encoding the information directly into the token itself.  
To be effective, such references must be infeasible for an attacker to
guess.  Using a reference may require an extra interaction between the
resource server and the authorization server; the mechanics of such an
interaction are not defined by this specification.*

At this point, **the authorization flow is complete**.

##### Experimental: Authorization Details for Multiple Servers {%include exp.html%}

{%include exp-div.html%}
If an authorization server wishes to provide a token that can be used with more than one FHIR server (i.e., the token can be used with app's requested `aud` as well as additional endpoints), the following structures from [rfc9396](https://datatracker.ietf.org/doc/html/rfc9396) can be included in the access token response:

* `authorization_details` array of objects, where each object may include
  * `type` (required): fixed value `smart_on_fhir`
  * `locations` (required): array of FHIR base URLs. Including a URL in this list indicates that the access token may be used with this FHIR server.
  * `fhirVersions` (required): array of [FHIR Version](https://hl7.org/fhir/valueset-FHIR-version.html) codes (e.g., `4.0.1` for R4). Including a version in this list indicates that all servers in the `locations` array of this "authorization_details" object will support this version. Commonly there will be only a single location and a single version per "authorization details" object.
  * `scope` (optional): string with space-separate SMART scopes. When present, indicates scopes that are granted for use at the `locations`. When absent, the top-level scopes from the access token response will apply at the `locations`.
  * `patient`, `encounter`, `fhirContext` (optional). When present, these indicate the [SMART Launch Context](scopes-and-launch-context.html#launch-context-arrives-with-your-access_token) that applies at the `locations`. This allows server-specific context (e.g., allowing for different patient IDs for an R4 server vs R2 server). When a context parameter is absent, the top-level value from the access token response will apply at the `locations`.

For example, an access request to an R4 FHIR server could potentially result in a token response for the requested R4 server as well as an R2 server. Note that the launch context and scopes for the R2 server differ from the top-level values in this example (accounting for different resource types and ids):

```json
{
  "token_type": "Bearer",
  "patient": "r4-123-id",
  "scope": "launch/patient patient/MedicationRequest.rs patient/Patient.rs",
  "expires_in": 3600,
  "access_token": "eyJhbG...",
  "authorization_details": [{
    "type": "smart_on_fhir",
    "locations": ["https://ehr.example.org/fhir/r4"],
    "fhirVersions": ["4.0.1"],
  }, {
    "type": "smart_on_fhir",
    "locations": ["https://ehr.example.org/fhir/r2"],
    "fhirVersions": ["1.0.2"],
    "scope": "launch/patient patient/MedicationOrder.rs patient/Patient.rs",
    "patient": "r2-456-id"
  }]
}
```
</div>

#### Examples

* [Public client](example-app-launch-public.html#step-5-access-token)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-5-access-token)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-5-access-token)

<a id="step-6-fhir-api"></a>

### Access FHIR API

With a valid access token, the app can access protected EHR data by issuing a
FHIR API call to the FHIR endpoint on the EHR's resource server.

#### Request

From the access token response, an app has received an OAuth2 bearer-type access token (`access_token` property) that can be used to fetch FHIR Resources.  The app issues a request that includes an
`Authorization` header that presents the `access_token` as a "Bearer" token:

{% raw %}
    Authorization: Bearer {{access_token}}
{% endraw %}

(Note that in a real request, `{% raw %}{{access_token}}{% endraw %}`{:.language-text} is replaced
with the actual token value.)

#### Response

The resource server SHALL validate the access token and ensure that it has not expired and that its scope covers the requested resource.  The
resource server also validates that the `aud` parameter associated with the
authorization (see section <a href="#step-4-authorization-code">Obtain authorization code</a>) matches the resource server's own FHIR
endpoint.  The method used by the EHR to validate the access token is beyond
the scope of this specification but generally involves an interaction or
coordination between the EHR’s resource server and the authorization server.

On occasion, an app may receive a FHIR resource that contains a “reference” to
a resource hosted on a different resource server.  The app SHOULD NOT blindly
follow such references and send along its access_token, as the token may be
subject to potential theft.   The app SHOULD either ignore the reference, or
initiate a new request for access to that resource.


#### Example Request and Response

**Example**
``` text
GET https://ehr/fhir/Patient/123
Authorization: Bearer i8hweunweunweofiwweoijewiwe
```

**Response**
```
{
  "resourceType": "Patient",
  "birthDate": ...
}
```


<a id="step-7-refresh"></a>

### Refresh access token

Refresh tokens are issued to enable sessions to last longer than the validity period of an access token.  The app can use the `expires_in` field from the token response (see section <a href="#step-5-access-token">Obtain access token</a>) to determine when its access token will expire.  EHR implementers are also encouraged to consider using the [OAuth 2.0 Token Introspection Protocol](https://tools.ietf.org/html/rfc7662) to provide an introspection endpoint that clients can use to examine the validity and meaning of tokens. An app with "online access" can continue to get new access tokens as long as the end-user remains online.  Apps with "offline access" can continue to get new access tokens without the user being interactively engaged for cases where an application should have long-term access extending beyond the time when a user is still interacting with the client.

The app requests a refresh token in its authorization request via the `online_access` scope (for EHR Launch) or `offline_access` scope (for EHR or Standalone launch). See section <a href="scopes-and-launch-context.html">SMART on FHIR Access Scopes</a> for details.  A server can decide which client types (public or confidential) are eligible for offline access and able to receive a refresh token.  If granted, the EHR supplies a refresh_token in the token response.  A refresh token SHALL be bound to the same `client_id` and SHALL contain the same or a subset of the claims authorized for the access token with which it is associated. After an access token expires, the app requests a new access token by providing its refresh token to the EHR's token endpoint.


#### Request

An HTTP `POST` transaction is made to the EHR authorization server's token URL, with content-type `application/x-www-form-urlencoded`. The decision about how long the refresh token lasts is determined by a mechanism that the server chooses.  For clients with online access, the goal is to ensure that the user is still online.

- For <span class="label label-primary">public apps</span>, authentication is not possible (and thus not required). For <span class="label label-primary">confidential apps</span>, see authentication considerations in
<a href="#step-5-access-token">step 5</a>.

The following request parameters are defined:

<table class="table">
  <thead>
    <th colspan="3">Parameters</th>
  </thead>
  <tbody>

    <tr>
      <td><code>grant_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: <code>refresh_token</code>. </td>
    </tr>
    <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The refresh token from a prior authorization response</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>
The scopes of access requested. If present, this value must be a strict sub-set
of the scopes granted in the original launch (no new permissions can be
obtained at refresh time). A missing value indicates a request for the same
scopes granted in the original launch.
      </td>
    </tr>
  </tbody>
</table>

#### Response

The response is a JSON object containing a new access token, with the following claims:

<table class="table">
  <thead>
    <th colspan="3">JSON Object property name</th>
  </thead>
  <tbody>
    <tr>
      <td><code>access_token</code></td>
      <td><span class="label label-success">required</span></td>
      <td>New access token issued by the authorization server.</td>
    </tr>
    <tr>
      <td><code>token_type</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Fixed value: bearer</td>
    </tr>
    <tr>
      <td><code>expires_in</code></td>
      <td><span class="label label-success">required</span></td>
      <td>The lifetime in seconds of the access token. For example, the value 3600 denotes that the access token will expire in one hour from the time the response was generated.</td>
    </tr>
    <tr>
      <td><code>scope</code></td>
      <td><span class="label label-success">required</span></td>
      <td>Scope of access authorized. Note that this will be the same as the scope of the original access token, and it can be different from the scopes requested by the app.</td>
    </tr>
    <tr>
      <td><code>refresh_token</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>The refresh token issued by the authorization server. If present, the app should discard any previous <code>refresh_token</code> associated with this launch and replace it with this new value.</td>
    </tr> 
    <tr>
      <td><code>authorization_details{%include exp.html%}</code></td>
      <td><span class="label label-info">optional</span></td>
      <td>{%include exp-span.html%}Additional details describing where this token can be used, and any per-location context (experimental; see <a href="#experimental-authorization-details-for-multiple-servers-exp">details</a>)</span></td>
    </tr>
  </tbody>
</table>

In addition, if the app was launched from within a patient context,
parameters to communicate the context values MAY BE included. For example,
a parameter like `"patient": "123"` would indicate the FHIR resource
https://[fhir-base]/Patient/123. Other context parameters may also
be available. For full details see [SMART launch context parameters](scopes-and-launch-context.html).



#### Examples

* [Public client](example-app-launch-public.html#step-7-refresh)
* [Confidential client, asymmetric authentication](example-app-launch-asymmetric-auth.html#step-7-refresh)
* [Confidential client, symmetric authentication](example-app-launch-symmetric-auth.html#step-7-refresh)


[.well-known/smart-configuration]: conformance.html#using-well-known
